#!/usr/bin/env bash

set -e

# Parse command line arguments
JSON_MODE=false
ARGS=()

for arg in "$@"; do
    case "$arg" in
        --json) 
            JSON_MODE=true 
            ;;
        --help|-h) 
            echo "Usage: $0 [--json]"
            echo "  --json    Output results in JSON format"
            echo "  --help    Show this help message"
            exit 0 
            ;;
        *) 
            ARGS+=("$arg") 
            ;;
    esac
done

# Get script directory and load common functions
SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# Get all paths and variables from common functions
eval $(get_task_paths)

# Check if we're on a proper feature branch (only for git repos)
check_feature_branch "$CURRENT_BRANCH" "$HAS_GIT" || exit 1

# Ensure the task directory exists
mkdir -p "$TASK_DIR"

# Copy plan template if it exists
TEMPLATE="$REPO_ROOT/.teammate/templates/plan-template.md"
if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$IMPL_TASKS"
    echo "Copied plan template to $IMPL_TASKS"
else
    echo "Warning: Plan template not found at $TEMPLATE"
    # Create a basic plan file if template doesn't exist
    touch "$IMPL_TASKS"
fi

# Output results
if $JSON_MODE; then
    printf '{"TASK_SPEC":"%s","IMPL_TASKS":"%s","TASK_DIR":"%s","BRANCH":"%s","HAS_GIT":"%s"}\n' \
        "$TASK_SPEC" "$IMPL_TASKS" "$TASK_DIR" "$CURRENT_BRANCH" "$HAS_GIT"
else
    echo "TASK_SPEC: $TASK_SPEC"
    echo "IMPL_TASKS: $IMPL_TASKS" 
    echo "TASK_DIR: $TASK_DIR"
    echo "BRANCH: $CURRENT_BRANCH"
    echo "HAS_GIT: $HAS_GIT"
fi

