---
description: Pre-ship gate — final verification across all systems before deployment. Staged rollout support.
handoffs:
  - label: Fix blockers
    agent: speckit.execute
    prompt: Fix blocking issues before ship
    send: true
  - label: Retrospective
    agent: speckit.retro
    prompt: Run engineering retrospective after successful ship
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Overview

Final verification gate before deployment. Checks all upstream gates (spec-ops + experience-kit + spec-kit) and optionally supports staged rollout.

### Argument Parsing

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Full pre-ship check |
| `--dry-run` | Check only, no deploy actions |
| `--stage canary` | Canary deployment (if infra supports) |
| `--stage progressive` | Progressive rollout (canary → 10% → 50% → 100%) |
| `--skip-upstream` | Skip spec-ops/experience-kit gate checks (requires confirmation) |

---

## Phase 0: Load Context

Per `speckit/references/command-shared`. Also:
- Read `SPEC_DIR` from prerequisites check
- Read `context.md` for deployment constraints
- Read `principles.md` for deployment-related MUST rules

---

## Phase 1: Upstream Gate Verification

### 1a. spec-ops Gate

Scan `specs/*/result.json`:

| Check | Criteria | Blocking? |
|-------|----------|-----------|
| Product spec verdict | Must be Pass or Conditional | Yes |
| Conditional items | All `top_improvements` addressed in implementation | No (WARN) |

If no `result.json` → WARN (no product spec quality gate).

### 1b. experience-kit Gate

Scan `design/audit/reports/*.md` (most recent):

| Check | Criteria | Blocking? |
|-------|----------|-----------|
| Audit verdict | Must be PASS or WARN (not FAIL) | Yes |
| Token drift | Zero T6/T7 FAIL items | Yes |
| Visual quality | VQ total ≥ 15/24 | No (WARN) |

If no audit report → WARN (no design audit gate).

### 1c. spec-kit Gate

| Check | Source | Criteria | Blocking? |
|-------|--------|----------|-----------|
| Review readiness | `checklists/feature-readiness.md` | Readiness: Ready | Yes |
| Validate result | Validate report | No CRITICAL findings | Yes |
| QA result | `checklists/qa-report.md` | P1 E2E pass, zero critical a11y | Yes |
| Unverified actions | `plan.md` `- [~]` items | Zero unverified | Yes |
| Open TODOs | Codebase `TODO:` scan | No blocking TODOs | No (WARN) |

---

## Phase 2: Code Quality Checks

| Check | Method | Blocking? |
|-------|--------|-----------|
| Build passes | `npm run build` / framework equivalent | Yes |
| No TypeScript errors | `tsc --noEmit` (if applicable) | Yes |
| Lint clean | `npm run lint` (if configured) | No (WARN) |
| No console.log | Scan for debug statements | No (WARN) |
| No hardcoded secrets | Scan for API keys, tokens, passwords | Yes |
| Dependencies clean | No known vulnerabilities (`npm audit`) | No (WARN) |

---

## Phase 3: Ship Readiness Report

```markdown
## Ship Readiness Report

### Upstream Gates
| Gate | Source | Status |
|------|--------|--------|
| spec-ops | result.json | [PASS/WARN/FAIL/MISSING] |
| experience-kit | audit report | [PASS/WARN/FAIL/MISSING] |
| spec-kit review | feature-readiness.md | [PASS/FAIL] |
| spec-kit validate | validate report | [PASS/FAIL] |
| spec-kit QA | qa-report.md | [PASS/FAIL/MISSING] |

### Code Quality
| Check | Status |
|-------|--------|
| Build | [PASS/FAIL] |
| Types | [PASS/FAIL/N/A] |
| Lint | [PASS/WARN/N/A] |
| Secrets | [PASS/FAIL] |

### Verdict
[SHIP / SHIP WITH CAUTION / DO NOT SHIP]

### Blocking Issues
[list if any]

### Warnings
[list if any]
```

---

## Phase 4: Deploy (if not --dry-run)

Only after verdict = SHIP or SHIP WITH CAUTION (with user confirmation):

| Stage | Action | Rollback Trigger |
|-------|--------|-----------------|
| `canary` | Deploy to canary environment | Error rate > baseline |
| `progressive` | 10% → wait → 50% → wait → 100% | Error rate spike at any stage |
| _(default)_ | Standard deployment per project config | Manual |

> Deploy commands are project-specific. `/speckit.ship` orchestrates the gate checks;
> actual deployment uses the project's configured deploy script or CI/CD pipeline.

---

## Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: ship
- **Last**: ship — [SHIP/DO NOT SHIP], [N] blockers
- **Next**: /speckit.retro | fix blockers
- Include: verdict, gate summary, blocking issues

## Operating Principles

> Common rules: see `speckit/references/command-shared`.

- Read-only for gate checks; deploy only with explicit user consent
- Never bypass blocking gates silently
- `--skip-upstream` requires explicit confirmation (type `SKIP UPSTREAM`)
- Log all gate results for traceability
