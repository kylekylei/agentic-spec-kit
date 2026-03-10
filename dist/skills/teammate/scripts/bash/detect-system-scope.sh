#!/usr/bin/env bash

# detect-system-scope.sh
#
# Scans the codebase to detect active system layers and compliance requirements.
# Called by teammate.plan.md during Architecture planning.
#
# Usage: ./detect-system-scope.sh [--json]
#
# OUTPUT (JSON):
# {
#   "layers": {
#     "frontend":  true/false,
#     "backend":   true/false,
#     "llm":       true/false,
#     "database":  true/false,
#     "mobile":    true/false
#   },
#   "compliance": ["a11y", "security", "ai-risk", "mobile-a11y"],
#   "evidence": { "frontend": "src/components/ detected", ... },
#   "missing_context": ["frontend detected but not in context.md"]
# }

set -e

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

JSON_MODE=false
for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    --help|-h)
      echo "Usage: detect-system-scope.sh [--json]"
      echo "Detects system layers and compliance requirements from the codebase."
      exit 0 ;;
    *) echo "ERROR: Unknown option '$arg'" >&2; exit 1 ;;
  esac
done

eval $(get_task_paths)

# ── Layer detection ──────────────────────────────────────────────────
detect_layer() {
  local name="$1"; shift
  local found=false; local evidence=""
  for sig in "$@"; do
    if find "$REPO_ROOT" -name "$sig" -not -path "*/node_modules/*" -not -path "*/.git/*" \
        2>/dev/null | grep -q .; then
      found=true; evidence="$sig matched"; break
    fi
  done
  echo "$name:$found:$evidence"
}

frontend_r=$(detect_layer "frontend" "*.tsx" "*.vue" "*.svelte")
backend_r=$(detect_layer  "backend"  "*controller.*" "*service.*" "*api.*")
llm_r=$(detect_layer      "llm"      "openai" "anthropic" "langchain")
database_r=$(detect_layer "database" "*model.*" "*entity.*" "prisma" "schema.sql")
mobile_r=$(detect_layer   "mobile"   "*.swift" "*.kt" "*.dart")

_val()  { echo "${1#*:}" | cut -d: -f1; }
_evid() { echo "${1##*:}"; }

fe=$(_val "$frontend_r"); be=$(_val "$backend_r")
ll=$(_val "$llm_r");      db=$(_val "$database_r"); mo=$(_val "$mobile_r")

# ── Compliance mapping ────────────────────────────────────────────────
compliance=()
[[ "$fe" == "true" ]] && compliance+=("a11y")
[[ "$be" == "true" || "$db" == "true" ]] && compliance+=("security-owasp")
[[ "$ll" == "true" ]] && compliance+=("ai-risk")
[[ "$mo" == "true" ]] && compliance+=("mobile-a11y")

# ── context.md drift check ────────────────────────────────────────────
missing_context=()
CONTEXT="$REPO_ROOT/.teammate/memory/context.md"
if [[ -f "$CONTEXT" ]]; then
  [[ "$fe" == "true" ]] && ! grep -qi "frontend\|react\|vue\|svelte" "$CONTEXT" 2>/dev/null \
    && missing_context+=("frontend detected but not in context.md")
  [[ "$ll" == "true" ]] && ! grep -qi "openai\|anthropic\|llm\|langchain" "$CONTEXT" 2>/dev/null \
    && missing_context+=("llm/ai detected but not in context.md")
fi

# ── Output ────────────────────────────────────────────────────────────
if $JSON_MODE; then
  comp_json=$(printf '"%s",' "${compliance[@]}" | sed 's/,$//'); comp_json="[${comp_json}]"
  mc_json=$(printf '"%s",' "${missing_context[@]}" | sed 's/,$//'); mc_json="[${mc_json}]"
  cat <<EOF
{
  "layers": {
    "frontend": $fe,
    "backend":  $be,
    "llm":      $ll,
    "database": $db,
    "mobile":   $mo
  },
  "compliance": $comp_json,
  "evidence": {
    "frontend": "$(_evid "$frontend_r")",
    "backend":  "$(_evid "$backend_r")",
    "llm":      "$(_evid "$llm_r")",
    "database": "$(_evid "$database_r")",
    "mobile":   "$(_evid "$mobile_r")"
  },
  "missing_context": $mc_json
}
EOF
else
  echo "=== System Scope ==="
  printf '  frontend:  %s\n  backend:   %s\n  llm:       %s\n  database:  %s\n  mobile:    %s\n' \
    "$fe" "$be" "$ll" "$db" "$mo"
  echo "COMPLIANCE: ${compliance[*]:-none}"
  [[ ${#missing_context[@]} -gt 0 ]] && { echo "⚠ CONTEXT DRIFT:"; printf '  - %s\n' "${missing_context[@]}"; }
fi
