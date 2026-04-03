#!/usr/bin/env bash
# speckit-skills.sh — Manage installed Skills & Agents
#
# Usage:
#   speckit-skills.sh [list|add|remove|detect] [args]
#   speckit-skills.sh list                    # show installed vs available
#   speckit-skills.sh add frontend_web        # add category
#   speckit-skills.sh add playwright           # add single skill
#   speckit-skills.sh remove testing           # remove category (blocks core)
#   speckit-skills.sh detect                   # scan project, suggest skills

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
SKILLS_YML="$REPO_ROOT/.specify/config/skills.yml"
REGISTRY_YML=""

# Colors
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
log()  { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }

CORE_SKILLS="speckit git-commit code-review code-refactoring"

# ── Resolve skill-registry.yml ──
resolve_registry() {
    for dir in .cursor .claude .agent; do
        local candidate="$REPO_ROOT/$dir/skills/skill-registry.yml"
        if [[ -f "$candidate" ]]; then
            REGISTRY_YML="$candidate"
            return 0
        fi
    done
    local speckit_home="${SPECKIT_HOME:-}"
    if [[ -n "$speckit_home" && -f "$speckit_home/templates/skills/skill-registry.yml" ]]; then
        REGISTRY_YML="$speckit_home/templates/skills/skill-registry.yml"
        return 0
    fi
    err "skill-registry.yml not found"
    return 1
}

# ── Parse skills from a YAML category block ──
parse_category_skills() {
    local category="$1"
    sed -n "/^  ${category}:/,/^  [a-z_]*:/p" "$REGISTRY_YML" \
        | grep -E '^\s+- [a-z]' \
        | grep -v 'name:' | grep -v 'description:' \
        | sed 's/^\s*- //'
}

# ── List all categories ──
list_categories() {
    grep -E '^  [a-z_]+:$' "$REGISTRY_YML" | sed 's/://; s/^  //'
}

# ── Check if skill is core ──
is_core() {
    local skill="$1"
    for core in $CORE_SKILLS; do
        [[ "$skill" == "$core" ]] && return 0
    done
    return 1
}

# ── list ──
cmd_list() {
    resolve_registry || exit 1

    echo ""
    if [[ ! -f "$SKILLS_YML" ]]; then
        warn "skills.yml not found — no skills configured yet"
        echo "Run /speckit.init to configure, or use: speckit-skills.sh add <category>"
        echo ""
        echo "Available categories:"
        while IFS= read -r cat; do
            local label
            label=$(sed -n "/^  ${cat}:/,/^  [a-z]/p" "$REGISTRY_YML" | grep 'label:' | head -1 | sed 's/.*label: *["'"'"']\{0,1\}//' | sed 's/["'"'"']\{0,1\}$//')
            local skills
            skills=$(parse_category_skills "$cat")
            local count
            count=$(echo "$skills" | grep -c . 2>/dev/null || echo 0)
            echo "  $cat ($count skills): $label"
        done < <(list_categories)
        return
    fi

    echo "Installed Skills:"
    echo ""

    local installed
    installed=$(sed -n '/^selected_skills:/,/^[a-z]/p' "$SKILLS_YML" | grep '^\s*- ' | sed 's/^\s*- //' | sort)
    local count
    count=$(echo "$installed" | grep -c . 2>/dev/null || echo 0)

    # Group by category
    while IFS= read -r cat; do
        local cat_skills
        cat_skills=$(parse_category_skills "$cat")
        local matched=""
        while IFS= read -r skill; do
            [[ -z "$skill" ]] && continue
            if echo "$installed" | grep -qx "$skill"; then
                matched+="$skill "
            fi
        done <<< "$cat_skills"
        if [[ -n "$matched" ]]; then
            local label
            label=$(sed -n "/^  ${cat}:/,/^  [a-z]/p" "$REGISTRY_YML" | grep 'label:' | head -1 | sed 's/.*label: *["'"'"']\{0,1\}//' | sed 's/["'"'"']\{0,1\}$//')
            local m_count
            m_count=$(echo "$matched" | wc -w | tr -d ' ')
            echo "  $cat ($m_count): $matched"
        fi
    done < <(list_categories)

    echo ""
    echo "Total: $count skills installed"

    # Show not installed
    local all_skills
    all_skills=$(for cat in $(list_categories); do parse_category_skills "$cat"; done | sort -u)
    local not_installed
    not_installed=$(comm -23 <(echo "$all_skills") <(echo "$installed") 2>/dev/null || true)

    if [[ -n "$not_installed" ]]; then
        local avail_count
        avail_count=$(echo "$not_installed" | grep -c . 2>/dev/null || echo 0)
        echo ""
        echo "Available but not installed ($avail_count):"
        echo "$not_installed" | sed 's/^/  /'
    fi
    echo ""
}

# ── add ──
cmd_add() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        err "Usage: speckit-skills.sh add <skill|category>"
        exit 1
    fi
    resolve_registry || exit 1

    # Ensure skills.yml exists
    if [[ ! -f "$SKILLS_YML" ]]; then
        mkdir -p "$(dirname "$SKILLS_YML")"
        cat > "$SKILLS_YML" <<'EOF'
version: 1
selected_skills: []
selected_agents: []
EOF
        log "Created skills.yml"
    fi

    local skills_to_add=""

    # Check if category
    if list_categories | grep -qx "$target"; then
        skills_to_add=$(parse_category_skills "$target")
        info "Adding category '$target':"
    else
        # Single skill — verify it exists in registry
        if grep -qE "^\s+- ${target}$" "$REGISTRY_YML" 2>/dev/null; then
            skills_to_add="$target"
        else
            err "Skill or category '$target' not found in registry"
            exit 1
        fi
    fi

    local added=0
    while IFS= read -r skill; do
        [[ -z "$skill" ]] && continue
        if grep -q "^\s*- ${skill}$" "$SKILLS_YML" 2>/dev/null; then
            warn "Already installed: $skill"
        else
            # Append after selected_skills:
            if [[ "$(uname)" == "Darwin" ]]; then
                sed -i '' "/^selected_skills:/a\\
  - ${skill}" "$SKILLS_YML"
            else
                sed -i "/^selected_skills:/a\\  - ${skill}" "$SKILLS_YML"
            fi
            log "Added: $skill"
            ((added++))
        fi
    done <<< "$skills_to_add"

    echo ""
    if [[ $added -gt 0 ]]; then
        info "Run speckit-sync.sh to apply changes"
    fi
}

# ── remove ──
cmd_remove() {
    local target="${1:-}"
    if [[ -z "$target" ]]; then
        err "Usage: speckit-skills.sh remove <skill|category>"
        exit 1
    fi

    if [[ ! -f "$SKILLS_YML" ]]; then
        err "skills.yml not found"
        exit 1
    fi

    resolve_registry || exit 1

    local skills_to_remove=""

    # Check if category
    if list_categories | grep -qx "$target"; then
        skills_to_remove=$(parse_category_skills "$target")
    else
        skills_to_remove="$target"
    fi

    local removed=0
    while IFS= read -r skill; do
        [[ -z "$skill" ]] && continue
        if is_core "$skill"; then
            warn "Cannot remove core skill: $skill"
            continue
        fi
        if [[ "$(uname)" == "Darwin" ]]; then
            sed -i '' "/^\s*- ${skill}$/d" "$SKILLS_YML"
        else
            sed -i "/^\s*- ${skill}$/d" "$SKILLS_YML"
        fi
        log "Removed: $skill"
        ((removed++))
    done <<< "$skills_to_remove"

    echo ""
    if [[ $removed -gt 0 ]]; then
        info "Run speckit-sync.sh to apply changes"
    fi
}

# ── detect ──
cmd_detect() {
    resolve_registry || exit 1

    echo ""
    info "Scanning project for skill recommendations..."
    echo ""

    local suggestions=()

    # package.json deps
    if [[ -f "$REPO_ROOT/package.json" ]]; then
        local pkg="$REPO_ROOT/package.json"
        for dep in react vue svelte angular next nuxt; do
            grep -q "\"$dep\"" "$pkg" 2>/dev/null && { suggestions+=("frontend_web"); break; }
        done
        grep -q '"tailwindcss"' "$pkg" 2>/dev/null && suggestions+=("frontend_tailwind")
        for dep in playwright "@playwright/test"; do
            grep -q "\"$dep\"" "$pkg" 2>/dev/null && { suggestions+=("testing"); break; }
        done
        for dep in express fastify nestjs django flask fastapi; do
            grep -q "\"$dep\"" "$pkg" 2>/dev/null && { suggestions+=("backend"); break; }
        done
    fi

    [[ -f "$REPO_ROOT/tsconfig.json" ]] && suggestions+=("frontend_typescript")
    [[ -f "$REPO_ROOT/go.mod" || -f "$REPO_ROOT/Cargo.toml" || -f "$REPO_ROOT/pyproject.toml" || -f "$REPO_ROOT/requirements.txt" ]] && suggestions+=("backend")

    # Docker
    command -v docker &>/dev/null && info "Docker CLI detected"
    [[ -f "$REPO_ROOT/Dockerfile" || -f "$REPO_ROOT/docker-compose.yml" ]] && info "Container config found"

    # Design
    local has_pen=false
    find "$REPO_ROOT" -maxdepth 2 -name "*.pen" -print -quit 2>/dev/null | grep -q . && suggestions+=("design")

    # Deduplicate
    local unique_suggestions
    unique_suggestions=$(printf '%s\n' "${suggestions[@]}" 2>/dev/null | sort -u)

    if [[ -z "$unique_suggestions" ]]; then
        log "No additional skill categories detected"
    else
        echo "Detected categories:"
        while IFS= read -r cat; do
            [[ -z "$cat" ]] && continue
            local label
            label=$(sed -n "/^  ${cat}:/,/^  [a-z]/p" "$REGISTRY_YML" | grep 'label:' | head -1 | sed 's/.*label: *["'"'"']\{0,1\}//' | sed 's/["'"'"']\{0,1\}$//')
            local skills
            skills=$(parse_category_skills "$cat" | tr '\n' ', ' | sed 's/,$//')
            echo "  $cat: $label ($skills)"
        done <<< "$unique_suggestions"

        # Compare with installed
        if [[ -f "$SKILLS_YML" ]]; then
            echo ""
            local installed
            installed=$(sed -n '/^selected_skills:/,/^[a-z]/p' "$SKILLS_YML" | grep '^\s*- ' | sed 's/^\s*- //')
            local missing=""
            while IFS= read -r cat; do
                [[ -z "$cat" ]] && continue
                local cat_skills
                cat_skills=$(parse_category_skills "$cat")
                while IFS= read -r skill; do
                    [[ -z "$skill" ]] && continue
                    if ! echo "$installed" | grep -qx "$skill"; then
                        missing+="  $skill ($cat)\n"
                    fi
                done <<< "$cat_skills"
            done <<< "$unique_suggestions"
            if [[ -n "$missing" ]]; then
                echo "Not yet installed:"
                echo -e "$missing"
            fi
        fi
    fi
    echo ""
}

# ── Main ──
subcmd="${1:-list}"
shift 2>/dev/null || true

case "$subcmd" in
    list)    cmd_list ;;
    add)     cmd_add "$@" ;;
    remove)  cmd_remove "$@" ;;
    detect)  cmd_detect ;;
    -h|--help)
        echo "Usage: speckit-skills.sh [list|add|remove|detect] [args]"
        echo ""
        echo "Commands:"
        echo "  list              Show installed vs available skills"
        echo "  add <name>        Add a skill or category"
        echo "  remove <name>     Remove a skill or category (core protected)"
        echo "  detect            Scan project and suggest skills"
        ;;
    *)  err "Unknown: $subcmd"; echo "Usage: speckit-skills.sh [list|add|remove|detect]"; exit 1 ;;
esac
