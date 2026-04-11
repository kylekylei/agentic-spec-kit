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

Scan `specs/*/reviews/*-spec-contract-v*.json` (prefer latest version).

**3 框架 gate** (from `quality_gates`):

| Check | Criteria | Blocking? |
|-------|----------|-----------|
| SQ verdict | Must be Pass or Conditional | Yes |
| DQ verdict (if triggered) | Must be Pass or Conditional | Yes |
| LQ verdict (if triggered) | Must be Pass or Conditional | Yes |
| `overall.top_improvements` | All addressed in implementation | No (WARN) |

**X1–X4 橫切合規 join gate** (from `crosscutting_compliance`):

| Check | Criteria | Blocking? |
|-------|----------|-----------|
| Each triggered X item verdict | Must be Pass (not Fail) | Yes |
| Enable-layer sub-chars | Must have AC-E-NNN contract test evidence | Yes |

**出貨天花板 gate**（from `context.md` Shipping Ceiling）:

| Ceiling | 行為 |
|---------|------|
| L4 | 完整驗證：SQ + DQ + LQ + X1-X4 + experience-contract 必須存在 |
| L3 | SQ + DQ + LQ + X1-X4，experience-contract optional |
| L2 | SQ + DQ/LQ (if triggered)，Enable AC 仍需 pass |
| L0-L1 | 輕量：SQ 聚焦 SQ2/SQ3/SQ8/SQ9 |

即使天花板 < L4，Enable AC（AC-E-NNN）的契約測試仍必須 pass。Enable 層的責任不因出貨天花板降低而免除——它確保上層未來能合規。

If no `spec-contract.json` found → WARN (no product spec quality gate).

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
| spec-ops | spec-contract.json | [PASS/WARN/FAIL/MISSING] |
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
