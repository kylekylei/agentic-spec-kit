#!/usr/bin/env bash
# Pre-command hook: validates foundation before speckit.* commands
# Exit 1 to block the command if foundation is incomplete

set -e

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# Only check for speckit lifecycle commands (not sync/skills/init)
COMMAND_NAME="${1:-}"
case "$COMMAND_NAME" in
    speckit.align|speckit.plan|speckit.execute|speckit.review|speckit.validate) ;;
    *) exit 0 ;;
esac

CONTEXT_FILE="$REPO_ROOT/.specify/memory/context.md"

if [[ ! -f "$CONTEXT_FILE" ]]; then
    echo "ERROR: context.md not found. Run /speckit.init first." >&2
    exit 1
fi

# Check for placeholder patterns
if grep -qE '\[([A-Z_]{3,})\]' "$CONTEXT_FILE" 2>/dev/null; then
    echo "WARNING: context.md contains placeholders. Run /speckit.init to complete." >&2
    # Don't block — warn only (partial is OK for some commands)
fi

exit 0
