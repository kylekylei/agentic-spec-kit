#!/usr/bin/env bash
# Foundation validation script
# Returns: {"context":"complete|partial|template|missing", "principles":"complete|partial|template|missing"}

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

REPO_ROOT=$(get_repo_root)
CONTEXT_FILE="$REPO_ROOT/.specify/memory/context.md"
PRINCIPLES_FILE="$REPO_ROOT/.specify/memory/principles.md"

check_placeholders() {
    local file=$1
    if [[ ! -f "$file" ]]; then
        echo "missing"
        return
    fi
    
    # Check for placeholder patterns
    if grep -q '\[ALL_CAPS_IDENTIFIER\]' "$file" || grep -q '\[PLACEHOLDER\]' "$file"; then
        # Check if file is mostly template (< 20 lines suggests template)
        local line_count=$(wc -l < "$file")
        if [[ $line_count -lt 20 ]]; then
            echo "template"
        else
            echo "partial"
        fi
    else
        echo "complete"
    fi
}

CONTEXT_STATUS=$(check_placeholders "$CONTEXT_FILE")
PRINCIPLES_STATUS=$(check_placeholders "$PRINCIPLES_FILE")

printf '{"context":"%s","principles":"%s"}\n' "$CONTEXT_STATUS" "$PRINCIPLES_STATUS"
