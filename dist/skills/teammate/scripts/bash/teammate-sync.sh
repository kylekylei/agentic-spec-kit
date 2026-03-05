#!/usr/bin/env bash
# teammate-sync.sh — Sync Teammate dist/ to consumer projects
#
# Usage:
#   teammate-sync.sh <target-project> [--platform cursor|claude|antigravity] [--dry-run]
#   teammate-sync.sh .                            # auto-detect platform
#   teammate-sync.sh ~/my-project --platform claude --dry-run

set -euo pipefail

TEAMMATE_HOME="${TEAMMATE_HOME:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"
DIST_DIR="$TEAMMATE_HOME/dist"
VERSION_FILE=".teammate-sync-version"
DRY_RUN=false
PLATFORM="auto"
TARGET_DIR=""
CHECK_MODE=false
SELF_UPDATE=false

# ── Colors ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }
dry()  { echo -e "${YELLOW}[dry-run]${NC} $*"; }

# ── Arg parsing ──
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --platform)     PLATFORM="$2"; shift 2 ;;
            --dry-run)      DRY_RUN=true; shift ;;
            --check)        CHECK_MODE=true; shift ;;
            --self-update)  SELF_UPDATE=true; shift ;;
            --help|-h)      usage; exit 0 ;;
            -*)             err "Unknown flag: $1"; usage; exit 1 ;;
            *)
                if [[ -z "$TARGET_DIR" ]]; then
                    TARGET_DIR="$1"; shift
                else
                    err "Unexpected argument: $1"; usage; exit 1
                fi
                ;;
        esac
    done
    TARGET_DIR="${TARGET_DIR:-.}"
    TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
}

usage() {
    cat <<'EOF'
Usage: teammate-sync.sh <target-project> [options]

Options:
  --platform cursor|claude|antigravity   Target platform (auto-detected if omitted)
  --dry-run                       Show what would change without writing
  --check                         Check if local sync is behind remote Hub
  --self-update                   Pull latest Hub from remote before syncing
  -h, --help                      Show this help

Environment:
  TEAMMATE_HOME    Path to Teammate repo (default: auto-detected from script location)
                   Fallback: read from **Teammate Hub**: `...` in teammatesync_rule.mdc
EOF
}

# ── Resolve TEAMMATE_HOME when called from a consumer project ──
# When the script lives inside a consumer project's .teammate/scripts/bash/,
# the auto-detected TEAMMATE_HOME points to the consumer project root (no dist/).
# This function looks for the real Hub path in teammatesync_rule.mdc.
resolve_teammate_home() {
    # If dist/ already exists at TEAMMATE_HOME, we're good
    [[ -d "$TEAMMATE_HOME/dist" ]] && return 0

    # Try to read Hub path from teammatesync_rule.mdc in target or cwd
    local candidates=(
        "$TARGET_DIR/.cursor/rules/teammatesync_rule.mdc"
        "$(pwd)/.cursor/rules/teammatesync_rule.mdc"
    )

    for rule_file in "${candidates[@]}"; do
        [[ -f "$rule_file" ]] || continue
        local hub_path
        hub_path=$(sed -n 's/.*\*\*Teammate Hub\*\*: `\([^`]*\)`.*/\1/p' "$rule_file" 2>/dev/null | head -1)
        if [[ -n "$hub_path" && "$hub_path" != *"TEAMMATE_HUB_PATH"* && -d "$hub_path/dist" ]]; then
            TEAMMATE_HOME="$hub_path"
            DIST_DIR="$TEAMMATE_HOME/dist"
            warn "TEAMMATE_HOME resolved from teammatesync_rule.mdc → $TEAMMATE_HOME"
            return 0
        fi
    done

    err "dist/ not found at $TEAMMATE_HOME"
    err ""
    err "If running from a consumer project, set the Hub path in one of:"
    err "  1. .cursor/rules/teammatesync_rule.mdc  →  **Teammate Hub**: \`/path/to/Teammate\`"
    err "  2. TEAMMATE_HOME env var                →  TEAMMATE_HOME=/path/to/Teammate ./teammate-sync.sh ."
    exit 1
}

# ── Platform detection ──
detect_platform() {
    if [[ -d "$TARGET_DIR/.cursor" ]]; then echo "cursor"
    elif [[ -d "$TARGET_DIR/.claude" || -f "$TARGET_DIR/CLAUDE.md" ]]; then echo "claude"
    elif [[ -d "$TARGET_DIR/.agent" ]]; then echo "antigravity"
    else echo ""
    fi
}

prompt_platform() {
    echo "Cannot detect target platform. Choose:"
    echo "  [1] Cursor       (.cursor/)"
    echo "  [2] Claude Code  (.claude/)"
    echo "  [3] Antigravity  (.agent/)"
    read -rp "Choice (1/2/3): " choice
    case "$choice" in
        1) PLATFORM="cursor" ;;
        2) PLATFORM="claude" ;;
        3) PLATFORM="antigravity" ;;
        *) err "Cancelled."; exit 1 ;;
    esac
}

# ── Version tracking ──
get_local_hash() {
    git -C "$TEAMMATE_HOME" rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

get_local_full_hash() {
    git -C "$TEAMMATE_HOME" rev-parse HEAD 2>/dev/null || echo "unknown"
}

get_local_date() {
    git -C "$TEAMMATE_HOME" log -1 --format='%ci' 2>/dev/null | cut -d' ' -f1,2 | cut -c1-16 || echo "unknown"
}

get_remote_url() {
    git -C "$TEAMMATE_HOME" remote get-url origin 2>/dev/null || echo ""
}

get_remote_hash() {
    git -C "$TEAMMATE_HOME" ls-remote origin HEAD 2>/dev/null | cut -f1 | cut -c1-7 || echo "unknown"
}

get_remote_full_hash() {
    git -C "$TEAMMATE_HOME" ls-remote origin HEAD 2>/dev/null | cut -f1 || echo "unknown"
}

is_dirty() {
    ! git -C "$TEAMMATE_HOME" diff --quiet 2>/dev/null
}

get_source_version() {
    local hash dirty=""
    hash=$(get_local_hash)
    local date
    date=$(get_local_date)
    if is_dirty; then dirty=" (dirty)"; fi
    echo "${hash} ${date}${dirty}"
}

write_version() {
    local dest="$1"
    local version_path="$dest/$VERSION_FILE"
    local local_hash local_date remote_url remote_hash dirty_flag=""
    local_hash=$(get_local_hash)
    local_date=$(get_local_date)
    remote_url=$(get_remote_url)
    remote_hash=$(get_remote_hash)
    if is_dirty; then dirty_flag="true"; else dirty_flag="false"; fi

    if $DRY_RUN; then
        dry "Write $version_path"
        dry "  platform: $PLATFORM"
        dry "  local_hash: $local_hash"
        dry "  local_date: $local_date"
        dry "  remote_url: $remote_url"
        dry "  remote_hash: $remote_hash"
        dry "  dirty: $dirty_flag"
        dry "  synced: $(date '+%Y-%m-%d %H:%M:%S')"
        return
    fi

    cat > "$version_path" <<VEOF
platform: $PLATFORM
local_hash: $local_hash
local_date: $local_date
remote_url: $remote_url
remote_hash: $remote_hash
dirty: $dirty_flag
synced: $(date '+%Y-%m-%d %H:%M:%S')
VEOF
    log "Version recorded → $version_path"
}

# ── Check: compare synced version against remote Hub ──
check_version() {
    local dest
    # Detect platform folder
    if [[ -f "$TARGET_DIR/.cursor/$VERSION_FILE" ]]; then
        dest="$TARGET_DIR/.cursor"
    elif [[ -f "$TARGET_DIR/.claude/$VERSION_FILE" ]]; then
        dest="$TARGET_DIR/.claude"
    elif [[ -f "$TARGET_DIR/.agent/$VERSION_FILE" ]]; then
        dest="$TARGET_DIR/.agent"
    else
        err "No $VERSION_FILE found in target. Run sync first."
        exit 1
    fi

    local version_path="$dest/$VERSION_FILE"
    info "Reading $version_path"

    local synced_hash synced_date synced_remote_url synced_time
    synced_hash=$(grep '^local_hash:' "$version_path" | sed 's/local_hash: *//')
    synced_date=$(grep '^local_date:' "$version_path" | sed 's/local_date: *//')
    synced_remote_url=$(grep '^remote_url:' "$version_path" | sed 's/remote_url: *//')
    synced_time=$(grep '^synced:' "$version_path" | sed 's/synced: *//')

    # Fallback for old format (source: hash date)
    if [[ -z "$synced_hash" ]]; then
        local source_line
        source_line=$(grep '^source:' "$version_path" | sed 's/source: *//')
        synced_hash=$(echo "$source_line" | cut -d' ' -f1)
        synced_date=$(echo "$source_line" | cut -d' ' -f2,3)
    fi

    echo ""
    echo "Teammate Version Check"
    echo "  Target:      $TARGET_DIR"
    echo "  Synced hash: $synced_hash ($synced_date)"
    echo "  Synced at:   $synced_time"
    echo ""

    # Fetch latest remote
    if [[ -z "$synced_remote_url" ]]; then
        # Fall back to TEAMMATE_HOME's origin
        synced_remote_url=$(get_remote_url)
    fi

    if [[ -z "$synced_remote_url" ]]; then
        err "No remote URL found. Cannot check for updates."
        exit 1
    fi

    info "Querying remote: $synced_remote_url"
    local latest_hash
    latest_hash=$(git ls-remote "$synced_remote_url" HEAD 2>/dev/null | cut -f1 | cut -c1-7)

    if [[ -z "$latest_hash" ]]; then
        err "Failed to reach remote. Check network or URL."
        exit 1
    fi

    local latest_date
    # Try to get date from local repo if hash exists locally
    latest_date=$(git -C "$TEAMMATE_HOME" log -1 --format='%ci' "$latest_hash" 2>/dev/null | cut -d' ' -f1,2 | cut -c1-16 || echo "unknown")

    echo "  Remote hash: $latest_hash ($latest_date)"
    echo ""

    if [[ "$synced_hash" == "$latest_hash" ]]; then
        log "Up to date — synced version matches remote HEAD"
    else
        warn "Update available"
        echo "  Local:  $synced_hash"
        echo "  Remote: $latest_hash"
        echo ""
        echo "  Run with --self-update to pull latest and re-sync:"
        echo "    teammate-sync.sh $TARGET_DIR --self-update"
    fi
}

# ── Self-update: pull latest Hub then sync ──
self_update_hub() {
    info "Pulling latest from remote..."

    if is_dirty; then
        warn "Hub has uncommitted changes. Stashing before pull..."
        git -C "$TEAMMATE_HOME" stash push -m "teammate-sync auto-stash $(date '+%Y%m%d-%H%M%S')"
    fi

    local pull_output
    pull_output=$(git -C "$TEAMMATE_HOME" pull --ff-only origin main 2>&1) || {
        err "Pull failed (non-fast-forward). Resolve manually in $TEAMMATE_HOME"
        echo "$pull_output" >&2
        exit 1
    }

    echo "$pull_output"
    log "Hub updated to $(get_local_hash)"
    echo ""
}

# ── Sync helpers ──
sync_dir() {
    local src="$1" dest="$2" label="$3"
    if $DRY_RUN; then
        local src_count dest_count
        src_count=$(find "$src" -type f 2>/dev/null | wc -l | tr -d ' ')
        dest_count=0
        [[ -d "$dest" ]] && dest_count=$(find "$dest" -type f 2>/dev/null | wc -l | tr -d ' ')
        dry "$label: $src_count files from source (currently $dest_count in target)"
        return
    fi
    mkdir -p "$dest"
    rsync -a --delete "$src/" "$dest/"
    local count
    count=$(find "$dest" -type f | wc -l | tr -d ' ')
    log "$label: $count files synced"
}

# ── Cursor sync ──
sync_cursor() {
    local dest="$TARGET_DIR/.cursor"

    info "Syncing to Cursor ($dest)"

    sync_dir "$DIST_DIR/commands" "$dest/commands" "commands"
    sync_dir "$DIST_DIR/rules"    "$dest/rules"    "rules"
    sync_dir "$DIST_DIR/skills"   "$dest/skills"   "skills"
    sync_dir "$DIST_DIR/agents"   "$dest/agents"   "agents"

    write_version "$dest"
}

# ── Antigravity: rules .mdc → .md with activation metadata ──
convert_rule_for_antigravity() {
    local src_file="$1" dest_file="$2"
    local always_apply="" globs="" description=""

    # Parse Cursor .mdc frontmatter
    local in_frontmatter=false
    local frontmatter_done=false
    local body=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! $frontmatter_done; then
            if [[ "$line" == "---" ]]; then
                if $in_frontmatter; then
                    frontmatter_done=true
                    continue
                else
                    in_frontmatter=true
                    continue
                fi
            fi
            if $in_frontmatter; then
                case "$line" in
                    alwaysApply:*) always_apply=$(echo "$line" | sed 's/alwaysApply: *//') ;;
                    globs:*)       globs=$(echo "$line" | sed 's/globs: *//') ;;
                    description:*) description=$(echo "$line" | sed 's/description: *//') ;;
                esac
                continue
            fi
        fi
        body+="$line"$'\n'
    done < "$src_file"

    # Determine Antigravity activation mode
    local activation="manual"
    local activation_detail=""

    if [[ "$always_apply" == "true" ]]; then
        activation="always_on"
    elif [[ -n "$globs" && "$globs" != " " ]]; then
        activation="glob"
        # Normalize: remove brackets and quotes for clean glob
        activation_detail=$(echo "$globs" | tr -d '[]"' | sed 's/^ *//')
    elif [[ -n "$description" ]]; then
        activation="model_decision"
        activation_detail="$description"
    fi

    if $DRY_RUN; then
        dry "  $(basename "$src_file" .mdc).md — activation: $activation${activation_detail:+ ($activation_detail)}"
        return
    fi

    # Write Antigravity .md with activation metadata header
    {
        echo "---"
        echo "activation: $activation"
        [[ -n "$activation_detail" ]] && echo "activation_detail: \"$activation_detail\""
        [[ -n "$description" ]] && echo "description: \"$description\""
        echo "---"
        echo ""
        printf '%s' "$body"
    } > "$dest_file"
}

sync_antigravity_rules() {
    local src="$DIST_DIR/rules"
    local dest="$TARGET_DIR/.agent/rules"

    if $DRY_RUN; then
        dry "rules (.mdc → .md with activation metadata):"
    else
        mkdir -p "$dest"
        rm -f "$dest"/*.md
    fi

    local count=0
    for f in "$src"/*.mdc; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f" .mdc)
        convert_rule_for_antigravity "$f" "$dest/${name}.md"
        ((count++))
    done

    if ! $DRY_RUN; then
        log "rules: $count files converted (.mdc → .md)"
    fi
}

# ── Antigravity: commands → workflows with title/description/steps ──
convert_command_to_workflow() {
    local src_file="$1" dest_file="$2"
    local description="" title=""
    local in_frontmatter=false
    local frontmatter_done=false
    local body=""

    # Extract command name from filename: teammate.align.md → teammate.align
    local cmd_name
    cmd_name=$(basename "$src_file" .md)
    title="$cmd_name"

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! $frontmatter_done; then
            if [[ "$line" == "---" ]]; then
                if $in_frontmatter; then
                    frontmatter_done=true
                    continue
                else
                    in_frontmatter=true
                    continue
                fi
            fi
            if $in_frontmatter; then
                case "$line" in
                    description:*) description=$(echo "$line" | sed 's/description: *//') ;;
                    # Skip Cursor-specific fields: handoffs, agent, send, label, prompt
                    handoffs:*|" "*)
                        if [[ "$line" =~ ^[[:space:]]+-[[:space:]] ]] || [[ "$line" =~ ^[[:space:]]+[a-z] ]]; then
                            continue
                        fi
                        ;;
                esac
                continue
            fi
        fi
        body+="$line"$'\n'
    done < "$src_file"

    # Strip Cursor-specific $ARGUMENTS blocks from body
    body=$(printf '%s' "$body" | sed '/^```text$/,/^```$/{ /\$ARGUMENTS/d; }')

    if $DRY_RUN; then
        dry "  /$cmd_name — $description"
        return
    fi

    {
        echo "---"
        echo "title: \"$title\""
        echo "description: \"$description\""
        echo "---"
        echo ""
        printf '%s' "$body"
    } > "$dest_file"
}

sync_antigravity_workflows() {
    local src="$DIST_DIR/commands"
    local dest="$TARGET_DIR/.agent/workflows"

    if $DRY_RUN; then
        dry "workflows (commands → workflows with title/description):"
    else
        mkdir -p "$dest"
        rm -f "$dest"/*.md
    fi

    local count=0
    for f in "$src"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f")
        convert_command_to_workflow "$f" "$dest/$name"
        ((count++))
    done

    if ! $DRY_RUN; then
        log "workflows: $count files converted (commands → workflows)"
    fi
}

# ── Claude Code: rules .mdc → .md with description/globs frontmatter ──
convert_rule_for_claude() {
    local src_file="$1" dest_file="$2"
    local always_apply="" globs="" description=""

    local in_frontmatter=false
    local frontmatter_done=false
    local body=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! $frontmatter_done; then
            if [[ "$line" == "---" ]]; then
                if $in_frontmatter; then
                    frontmatter_done=true
                    continue
                else
                    in_frontmatter=true
                    continue
                fi
            fi
            if $in_frontmatter; then
                case "$line" in
                    alwaysApply:*) always_apply=$(echo "$line" | sed 's/alwaysApply: *//') ;;
                    globs:*)       globs=$(echo "$line" | sed 's/globs: *//') ;;
                    description:*) description=$(echo "$line" | sed 's/description: *//') ;;
                esac
                continue
            fi
        fi
        body+="$line"$'\n'
    done < "$src_file"

    if $DRY_RUN; then
        local mode="description-based"
        [[ -n "$globs" && "$globs" != " " ]] && mode="glob ($globs)"
        [[ "$always_apply" == "true" ]] && mode="always loaded"
        dry "  $(basename "$src_file" .mdc).md — $mode"
        return
    fi

    # Claude Code rules support description and globs in frontmatter-like comments
    # .claude/rules/*.md — Claude uses description for model-decision, globs for file-scoped
    {
        if [[ -n "$description" || ( -n "$globs" && "$globs" != " " ) ]]; then
            echo "---"
            [[ -n "$description" ]] && echo "description: $description"
            if [[ -n "$globs" && "$globs" != " " ]]; then
                local clean_globs
                clean_globs=$(echo "$globs" | tr -d '[]"' | sed 's/^ *//')
                echo "globs: $clean_globs"
            fi
            echo "---"
            echo ""
        fi
        printf '%s' "$body"
    } > "$dest_file"
}

sync_claude_rules() {
    local src="$DIST_DIR/rules"
    local dest="$TARGET_DIR/.claude/rules"

    if $DRY_RUN; then
        dry "rules (.mdc → .md):"
    else
        mkdir -p "$dest"
        rm -f "$dest"/*.md
    fi

    local count=0
    for f in "$src"/*.mdc; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f" .mdc)
        convert_rule_for_claude "$f" "$dest/${name}.md"
        ((count++))
    done

    if ! $DRY_RUN; then
        log "rules: $count files converted (.mdc → .md)"
    fi
}

# ── Claude Code: commands → .claude/commands/ (strip handoffs, keep $ARGUMENTS) ──
convert_command_for_claude() {
    local src_file="$1" dest_file="$2"
    local description=""
    local in_frontmatter=false
    local frontmatter_done=false
    local in_handoffs=false
    local body=""

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! $frontmatter_done; then
            if [[ "$line" == "---" ]]; then
                if $in_frontmatter; then
                    frontmatter_done=true
                    in_handoffs=false
                    continue
                else
                    in_frontmatter=true
                    continue
                fi
            fi
            if $in_frontmatter; then
                case "$line" in
                    description:*) description=$(echo "$line" | sed 's/description: *//') ;;
                    handoffs:*)    in_handoffs=true; continue ;;
                esac
                # Skip indented lines under handoffs
                if $in_handoffs; then
                    if [[ "$line" =~ ^[[:space:]] ]]; then
                        continue
                    else
                        in_handoffs=false
                    fi
                fi
                continue
            fi
        fi
        body+="$line"$'\n'
    done < "$src_file"

    local cmd_name
    cmd_name=$(basename "$src_file" .md)

    if $DRY_RUN; then
        dry "  /$cmd_name — $description"
        return
    fi

    {
        echo "---"
        echo "description: $description"
        echo "---"
        echo ""
        printf '%s' "$body"
    } > "$dest_file"
}

sync_claude_commands() {
    local src="$DIST_DIR/commands"
    local dest="$TARGET_DIR/.claude/commands"

    if $DRY_RUN; then
        dry "commands (strip handoffs, keep \$ARGUMENTS):"
    else
        mkdir -p "$dest"
        rm -f "$dest"/*.md
    fi

    local count=0
    for f in "$src"/*.md; do
        [[ -f "$f" ]] || continue
        local name
        name=$(basename "$f")
        convert_command_for_claude "$f" "$dest/$name"
        ((count++))
    done

    if ! $DRY_RUN; then
        log "commands: $count files converted (handoffs stripped)"
    fi
}

# ── Claude Code sync ──
sync_claude() {
    local dest="$TARGET_DIR/.claude"

    info "Syncing to Claude Code ($dest)"

    sync_claude_commands
    sync_claude_rules
    sync_dir "$DIST_DIR/skills" "$dest/skills" "skills"
    sync_dir "$DIST_DIR/agents" "$dest/agents" "agents"

    write_version "$dest"
}

# ── Antigravity sync ──
sync_antigravity() {
    local dest="$TARGET_DIR/.agent"

    info "Syncing to Antigravity ($dest)"

    sync_antigravity_workflows
    sync_antigravity_rules
    sync_dir "$DIST_DIR/skills" "$dest/skills" "skills"
    sync_dir "$DIST_DIR/agents" "$dest/agents" "agents"

    write_version "$dest"
}

# ── Main ──
main() {
    parse_args "$@"

    # Ensure TEAMMATE_HOME points to actual Hub (with dist/), not consumer project root
    resolve_teammate_home

    # --check: read version file and compare against remote (no sync)
    if $CHECK_MODE; then
        check_version
        return
    fi

    # --self-update: pull Hub before syncing
    if $SELF_UPDATE; then
        self_update_hub
    fi

    if [[ "$PLATFORM" == "auto" ]]; then
        PLATFORM=$(detect_platform)
    fi
    if [[ -z "$PLATFORM" ]]; then
        prompt_platform
    fi

    echo ""
    echo "Teammate Sync"
    echo "  Source:   $DIST_DIR"
    echo "  Target:   $TARGET_DIR"
    echo "  Platform: $PLATFORM"
    $DRY_RUN && echo "  Mode:     DRY RUN"
    echo ""

    case "$PLATFORM" in
        cursor)       sync_cursor ;;
        claude)       sync_claude ;;
        antigravity)  sync_antigravity ;;
        *)            err "Unknown platform: $PLATFORM"; exit 1 ;;
    esac

    echo ""
    if $DRY_RUN; then
        warn "Dry run complete — no files were modified"
    else
        log "Sync complete"
    fi
}

main "$@"
