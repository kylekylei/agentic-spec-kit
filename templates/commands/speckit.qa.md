---
description: E2E quality assurance — Playwright browser testing, visual regression, accessibility audit. Independent QA stage after validate.
handoffs:
  - label: Fix failures
    agent: speckit.execute
    prompt: Fix failing E2E tests and accessibility issues
    send: true
  - label: Ship it
    agent: speckit.ship
    prompt: All QA passed, proceed to pre-ship gate
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Overview

Independent QA stage using **real browser testing** (Playwright). Separated from `/speckit.validate` because:
- Validate = static analysis (code review, architecture, security scan)
- QA = dynamic verification (browser rendering, user flows, visual regression, a11y audit)

### Argument Parsing

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Full QA (all applicable suites) |
| `e2e` | E2E user flow tests only |
| `visual` | Visual regression tests only |
| `a11y` | Accessibility audit only |
| `smoke` | Smoke test subset (P1 flows only) |
| `--headed` | Run in headed mode (visible browser) |
| `--update-snapshots` | Update visual regression baselines |

### Division with other commands

| | `/speckit.review` | `/speckit.validate` | `/speckit.qa` (this) |
|---|---|---|---|
| Role | Behavior coverage gate | Deep static validation | Dynamic browser testing |
| Method | Artifact analysis | Code scanning | Playwright execution |
| Timing | After execute | After review | After validate |
| Browser | No | No | **Yes** |

---

## Phase 0: Setup

### Load Context

Per `speckit/references/command-shared`. Also:
- Read `SPEC_DIR` from prerequisites check
- Detect project framework (SvelteKit, Next.js, Nuxt, etc.)
- Check Playwright installation: `npx playwright --version`

### Prerequisites

| Prerequisite | Required | Fallback |
|---|---|---|
| Playwright installed | Yes | `npx playwright install` (prompt user) |
| Dev server runnable | Yes | Attempt `npm run dev` / `pnpm dev` |
| Test files exist | No | Generate from spec.md AC (Phase 1) |

---

## Phase 1: Test Scaffold (if needed)

If `SPEC_DIR/scenarios/*.feature` exist but no corresponding `*.spec.ts` Playwright files:

1. Read spec.md Acceptance Criteria
2. Read `scenarios/*.feature` for Given/When/Then
3. Generate Playwright test scaffolds:
   - One test file per feature file
   - Page Object Model for each screen in plan.md
   - Test data from example-mapping.md
4. Write to `tests/e2e/` (or project-configured test directory)

**Rules**:
- Tests verify **behavior** (what user sees), not implementation
- Use `data-testid` selectors (prefer over CSS selectors)
- Each test is independently runnable
- Tag alignment: `test.describe('@AC-001', ...)` matches spec AC IDs

---

## Phase 2: E2E User Flow Tests

### Execution

1. Start dev server (if not running)
2. Execute Playwright tests:
   ```
   npx playwright test --reporter=json,html
   ```
3. Capture results + screenshots on failure

### Coverage Mapping

| AC ID | Test File | Status | Screenshot | Duration |
|-------|-----------|--------|------------|----------|
| AC-001 | login.spec.ts | Pass/Fail | [link] | Nms |

### Priority Execution Order

1. **P1 Happy Path** — core user flows must pass
2. **P1 Negative** — error handling flows
3. **P2 Alternative** — secondary paths
4. **P3 Edge Cases** — boundary conditions

---

## Phase 3: Visual Regression (Optional)

> Triggered when: visual baseline snapshots exist OR `--update-snapshots` flag.

1. Capture current screenshots per screen in plan.md
2. Compare against baseline (if exists):
   - Pixel diff threshold: configurable (default 0.1%)
   - Highlight changed regions
3. Report visual changes:

| Screen | Baseline | Current | Diff % | Status |
|--------|----------|---------|--------|--------|
| Login | [img] | [img] | 0.02% | Pass |

`--update-snapshots` → save current as new baseline.

---

## Phase 4: Accessibility Audit

1. Run axe-core via Playwright on each unique screen:
   ```typescript
   import AxeBuilder from '@axe-core/playwright';
   const results = await new AxeBuilder({ page }).analyze();
   ```
2. Check WCAG 2.2 AA compliance
3. Report by POUR principle:

| Principle | Checks | Pass | Fail | Impact |
|-----------|--------|------|------|--------|
| Perceivable | [N] | [N] | [N] | [critical/serious/moderate] |
| Operable | [N] | [N] | [N] | ... |
| Understandable | [N] | [N] | [N] | ... |
| Robust | [N] | [N] | [N] | ... |

### Severity Mapping

- **axe critical/serious** → QA CRITICAL
- **axe moderate** → QA HIGH
- **axe minor** → QA MEDIUM

---

## Phase 5: Report

Generate `SPEC_DIR/checklists/qa-report.md`:

```markdown
## QA Report

### Summary
| Suite | Tests | Pass | Fail | Skip | Duration |
|-------|-------|------|------|------|----------|
| E2E | [N] | [N] | [N] | [N] | [T] |
| Visual | [N] | [N] | [N] | — | [T] |
| A11y | [N] | [N] | [N] | — | [T] |

### Failures
| # | Suite | Test | Error | Screenshot | Severity |
|---|-------|------|-------|------------|----------|

### A11y Issues
| # | Rule | Impact | Element | Fix |
|---|------|--------|---------|-----|

### Conclusion
[ALL PASS / PASS WITH CONDITIONS / FAIL]
```

### QA Gate

| Gate | Criteria | Blocking? |
|------|----------|-----------|
| P1 E2E | All P1 happy path tests pass | Yes |
| P1 Negative | All P1 error handling tests pass | Yes |
| A11y Critical | Zero critical a11y violations | Yes |
| A11y Serious | Zero serious a11y violations | Yes |
| Visual Regression | Diff < threshold | No (review required) |
| P2/P3 Coverage | > 60% pass rate | No |

---

## Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: qa
- **Last**: qa — [ALL PASS/FAIL], [N] e2e pass, [N] a11y issues
- **Next**: /speckit.ship | fix failures
- Include: path to qa-report.md, pass/fail counts, blocking issues

## Operating Principles

> Common rules: see `speckit/references/command-shared`.

- Tests must be deterministic — no flaky assertions
- Screenshot on every failure (automatic)
- Never modify source code — QA is read-only + test execution
- Prefer `data-testid` over fragile selectors
- A11y violations from axe-core are authoritative
