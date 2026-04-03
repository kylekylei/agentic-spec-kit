#!/usr/bin/env bash

# load-execution-context.sh
#
# Resolves and outputs the list of context files that execute.md must load.
# Follows the speckit context loading protocol for the execution phase.
#
# Usage: ./load-execution-context.sh --json
#
# OUTPUT (JSON):
# {
#   "required":  ["plan.md", "scenarios/*.feature"],
#   "loaded":    ["insights.md", "agent-spec.md", "contracts/", ...],
#   "skipped":   ["llms.txt (not found)", ...],
#   "compliance": ["a11y-compliance/SKILL.md"]
# }

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    --help|-h)
      echo "Usage: load-execution-context.sh [--json]"
      echo "Resolves execution-phase context files from TASK_DIR."
      exit 0 ;;
    *) echo "ERROR: Unknown option '$arg'" >&2; exit 1 ;;
  esac
done

eval $(get_task_paths)

# ── Required (always loaded) ─────────────────────────────────────────
required=("plan.md" "scenarios/*.feature")

# ── Conditional must-load (present = must load, no exceptions) ───────
loaded=()
skipped=()

_check() {
  local label="$1"; local path="$2"
  if [[ -e "$path" ]]; then
    loaded+=("$label")
  else
    skipped+=("$label (not found)")
  fi
}

_check "insights.md"                "$TASK_DIR/insights.md"
_check "agent-spec.md"              "$TASK_DIR/../memory/agent-spec.md"
_check "contracts/"                 "$TASK_DIR/contracts"
_check "data-model.md"              "$TASK_DIR/data-model.md"
_check "research.md"                "$TASK_DIR/research.md"

# Recent completed task insights (up to 2)
insight_count=0
while IFS= read -r insight_file && [[ $insight_count -lt 2 ]]; do
  task_dir=$(dirname "$insight_file")
  branch_name=$(basename "$task_dir")
  if [[ "$branch_name" != "$(basename "$TASK_DIR")" ]]; then
    loaded+=("past:$branch_name/insights.md")
    ((insight_count++))
  fi
done < <(find "$REPO_ROOT/specs" -name "insights.md" -newer "$TASK_DIR" 2>/dev/null | sort -r)

# llms.txt (library docs)
if [[ -f "$REPO_ROOT/docs/llms.txt" ]]; then
  loaded+=("docs/llms.txt")
else
  skipped+=("docs/llms.txt (not found)")
fi

# ── Compliance Skills (auto-detect from tech stack) ──────────────────
compliance=()
if grep -rq --include="*.tsx" --include="*.vue" --include="*.svelte" . 2>/dev/null; then
  [[ -f "$REPO_ROOT/skills/a11y-compliance/SKILL.md" ]] && compliance+=("a11y-compliance/SKILL.md")
fi
if grep -rq "openai\|anthropic\|langchain" "$REPO_ROOT/package.json" "$REPO_ROOT/requirements.txt" 2>/dev/null; then
  [[ -f "$REPO_ROOT/skills/ai-compliance/SKILL.md" ]] && compliance+=("ai-compliance/SKILL.md")
fi

# ── Output ────────────────────────────────────────────────────────────
if $JSON_MODE; then
  to_json_array() {
    local arr=("$@")
    if [[ ${#arr[@]} -eq 0 ]]; then echo "[]"; return; fi
    printf '"%s",' "${arr[@]}" | sed 's/,$//' | { echo -n "["; cat; echo "]"; }
  }
  printf '{"required":%s,"loaded":%s,"skipped":%s,"compliance":%s}\n' \
    "$(to_json_array "${required[@]}")" \
    "$(to_json_array "${loaded[@]}")" \
    "$(to_json_array "${skipped[@]}")" \
    "$(to_json_array "${compliance[@]}")"
else
  echo "=== Execution Context ==="
  echo "REQUIRED:"
  printf '  ✓ %s\n' "${required[@]}"
  echo "LOADED:"
  [[ ${#loaded[@]} -gt 0 ]] && printf '  ✓ %s\n' "${loaded[@]}" || echo "  (none)"
  echo "SKIPPED:"
  [[ ${#skipped[@]} -gt 0 ]] && printf '  - %s\n' "${skipped[@]}" || echo "  (none)"
  echo "COMPLIANCE:"
  [[ ${#compliance[@]} -gt 0 ]] && printf '  ⚡ %s\n' "${compliance[@]}" || echo "  (none detected)"
fi
