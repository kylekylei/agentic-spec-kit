#!/usr/bin/env bash
# install.sh — Install framework into a target project
#
# Usage:
#   ./install.sh                        # Install into current directory
#   ./install.sh ~/my-project           # Install into specific project
#   ./install.sh ~/my-project --dry-run # Preview without writing
#
# Supports: Cursor, Claude Code, Antigravity

set -euo pipefail

SPECKIT_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYNC_SCRIPT="$SPECKIT_HOME/dist/skills/speckit/scripts/bash/speckit-sync.sh"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
err()  { echo -e "${RED}✗${NC} $*" >&2; }
info() { echo -e "${CYAN}→${NC} $*"; }

usage() {
    cat <<EOF
Usage: ./install.sh [target-project] [options]

Arguments:
  target-project   Path to the project to install into (default: current directory)

Options:
  --dry-run        Preview what would be installed without writing files
  --platform       Force platform: cursor | claude | antigravity (auto-detected if omitted)
  -h, --help       Show this help

Examples:
  ./install.sh                          # Install into current directory
  ./install.sh ~/my-project             # Install into ~/my-project
  ./install.sh ~/my-project --dry-run   # Preview
  ./install.sh . --platform claude      # Force Claude Code
EOF
}

# ── Prerequisites ──
check_prereqs() {
    local missing=()
    command -v git   >/dev/null 2>&1 || missing+=("git")
    command -v rsync >/dev/null 2>&1 || missing+=("rsync")

    if [[ ${#missing[@]} -gt 0 ]]; then
        err "Missing required tools: ${missing[*]}"
        err "Please install them and retry."
        exit 1
    fi

    if [[ ! -f "$SYNC_SCRIPT" ]]; then
        err "Sync script not found: $SYNC_SCRIPT"
        err "Make sure you are running install.sh from the repo root."
        exit 1
    fi
}

# ── Already installed check ──
check_already_installed() {
    local target="$1"
    local version_file=""

    for f in "$target/.cursor/.speckit-sync-version" \
              "$target/.claude/.speckit-sync-version" \
              "$target/.agent/.speckit-sync-version"; do
        [[ -f "$f" ]] && version_file="$f" && break
    done

    if [[ -n "$version_file" ]]; then
        local synced_hash
        synced_hash=$(grep '^local_hash:' "$version_file" 2>/dev/null | sed 's/local_hash: *//' || echo "unknown")
        warn "Framework is already installed in $target (hash: $synced_hash)"
        warn "To update, use: ./install.sh $target --self-update"
        echo ""
        read -rp "  Continue anyway? (y/N): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]] || { info "Cancelled."; exit 0; }
        echo ""
    fi
}

# ── Main ──
main() {
    local target="."
    local extra_args=()

    # Parse args — pass through unknown flags to speckit-sync.sh
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) usage; exit 0 ;;
            --dry-run|--platform|--self-update)
                extra_args+=("$1")
                [[ "$1" == "--platform" ]] && { shift; extra_args+=("$1"); }
                shift ;;
            -*)
                extra_args+=("$1"); shift ;;
            *)
                target="$1"; shift ;;
        esac
    done

    target="$(cd "$target" && pwd)"

    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║        Framework Install              ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    info "Hub:    $SPECKIT_HOME"
    info "Target: $target"
    echo ""

    check_prereqs

    # Skip already-installed check for dry-run
    local is_dry_run=false
    for arg in "${extra_args[@]}"; do
        [[ "$arg" == "--dry-run" ]] && is_dry_run=true
    done
    $is_dry_run || check_already_installed "$target"

    # Delegate to speckit-sync.sh
    SPECKIT_HOME="$SPECKIT_HOME" bash "$SYNC_SCRIPT" "$target" "${extra_args[@]}"

    if ! $is_dry_run; then
        echo ""
        log "Installation complete!"
        echo ""
        echo "  Next steps:"
        echo "    1. Open your project in Cursor (or your IDE)"
        echo "    2. Run: /speckit.init"
        echo ""
    fi
}

main "$@"
