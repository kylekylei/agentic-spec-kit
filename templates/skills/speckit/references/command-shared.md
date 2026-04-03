---
name: speckit/references/command-shared
description: Shared patterns across speckit.* commands — context loading, prerequisites, active context update, completion report.
---

# Shared Command Patterns

## Phase 0: Load Context

- Foundation completeness verified by pre-command hook
- Load `context.md` (WHO/WHY/technical constraints + § Principles boundaries)
- `principles.md` = cold layer — only load during init/review deep checks

## Prerequisites Check

```
skills/speckit/scripts/bash/check-prerequisites.sh --json [flags]
```

| Flag | Effect |
|------|--------|
| `--paths-only` | Return SPEC_DIR, SPEC_PATH only |
| `--require-plan` | Fail if plan.md missing |
| `--include-plan` | Include plan content in output |

- Parse: `SPEC_DIR`, `AVAILABLE_DOCS`, `SPEC_PATH`
- Escape single quotes: `'I'\''m Groot'`

## Update Active Context

After command completes, update `context.md` § Current:

- **Foundation**: complete/partial/missing
- **Phase**: [command name]
- **Last**: [command] — [one-line summary]
- **Next**: [suggested next command]

## Completion Report

- Produced artifact file paths
- Key metrics / summary
- Readiness status (if applicable)
- Recommended next command

## Common Rules

- Auto-detect first, ask second
- Never fabricate — mark unknowns `TODO(<FIELD>): needs clarification`
- Idempotent — re-run preserves existing values
- Respect early-exit signals ("stop", "done", "proceed")
