#!/usr/bin/env bash
# Post-edit hook: runs type-check and lint after file edits
# Non-blocking — reports issues but doesn't fail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# TypeScript type-check
if [[ -f "$REPO_ROOT/tsconfig.json" ]]; then
    npx --no-install tsc --noEmit --pretty 2>/dev/null || true
fi

# ESLint (if config exists)
for cfg in .eslintrc .eslintrc.js .eslintrc.json .eslintrc.yml eslint.config.js eslint.config.mjs; do
    if [[ -f "$REPO_ROOT/$cfg" ]]; then
        npx --no-install eslint --quiet "${MODIFIED_FILE:-}" 2>/dev/null || true
        break
    fi
done

exit 0
