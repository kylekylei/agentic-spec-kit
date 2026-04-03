---
description: Quality gate — AC coverage analysis, consistency checks, feature readiness gate. For deep validation use /speckit.validate.
handoffs:
  - label: Deep validation
    agent: speckit.validate
    prompt: Run security, architecture, quality, and design deep validation
    send: true
  - label: Fix gaps
    agent: speckit.plan
    prompt: Update plan to address review findings
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Outline

- **Professional, neutral** analysis of behavior coverage, artifact consistency, and feature readiness
- Final verification gate: behavior review + requirements quality validation in one pass

### Constraints

**Strictly read-only**: Do not modify any files. Output only a structured analysis report.

**Principles are authoritative**: Project principles (`context.md` Principles section + full `principles.md`) are **non-negotiable**. Any principle conflict is CRITICAL.

**Professional tone**: Objective, constructive, suitable for team review. No sarcasm or inflammatory language.

### Phase 0: Load Context

1. **Load `context.md`** (warm layer) — WHO/WHY/technical constraints + Principles behavioral boundaries
2. **Load `principles.md`** (cold layer — full version needed for review depth checks)
   - **Parse all principles**: Extract every MUST / MUST NOT / SHOULD rule with its ID (e.g. `BB-001`, `III-D`) into an in-memory checklist for use in Pass B3, Pass D Compliance, and Pass G.

### Setup

Run prerequisites check (see `speckit/references/command-shared`) with `--json --require-plan --include-plan`. Parse:
- `SPEC_DIR`, `AVAILABLE_DOCS`

Derive paths:
   - SPEC = `SPEC_DIR/spec.md`
   - PLAN = `SPEC_DIR/plan.md` (Part 1: Tasks + Part 2: Actions)
   - FEATURES = `SPEC_DIR/scenarios/*.feature`
   - EXAMPLE_MAPPING = `SPEC_DIR/example-mapping.md`
   - UI_SPEC = `SPEC_DIR/contracts/ui/ui-spec.md` (if exists)
   - INSIGHTS = `SPEC_DIR/insights.md` (if exists)

Abort if required files are missing.

### Load Artifacts

- `spec.md`: user stories, functional requirements, success criteria
- `plan.md` Part 1 (Architecture): technical decisions, project structure, constraints
- `plan.md` Part 2 (Actions): actions with `[Verifies: @tag]` markers, phase structure
- `scenarios/*.feature`: all tagged scenarios, step definitions
- `principles`: principles and boundaries

---

## Pass A: Acceptance Criteria Coverage Analysis

#### AC Type Distribution

| Type | Count | Percentage | Target |
|------|-------|------------|--------|
| Happy Path | [N] | [%] | 30-40% |
| Alternative | [N] | [%] | 20-30% |
| Negative | [N] | [%] | 20-30% |
| Boundary | [N] | [%] | 10-15% |
| Principles | [N] | [%] | 5-10% |

#### User Story Coverage

| Story | ACs | Happy | Negative | Principles | Tests | Status |
|-------|-----|-------|----------|------------|-------|--------|
| US1 | [N] | [N] | [N] | [N] | [N/N] | [Complete/Gaps] |

#### Test Coverage Quality

- Do tests verify BEHAVIOR (what) rather than IMPLEMENTATION (how)?
- Does each AC have a corresponding test file?
- Are tests independently executable?

## Pass B: Consistency Analysis

#### B1. Traceability Verification
- Trace each requirement -> AC -> actions -> [Verifies: AC-001] -> test
- Report gaps: requirements without ACs, ACs without actions, actions without tests, orphan actions

#### B2. Terminology Consistency
- Is the same concept named consistently across files?
- Are entity names consistent across spec, model, and scenarios?

#### B3. Principles Alignment (item-by-item)

Using the principles checklist parsed in Phase 0, perform **item-by-item** verification:

1. **For each principle (MUST / MUST NOT / SHOULD)**:
   - Does it have at least one AC and corresponding test covering the boundary?
   - Does the implementation code comply? (spot-check relevant source files)
   - If the principle relates to accessibility (e.g. aria attributes, keyboard navigation), verify the **actual code** has the required attributes — do not assume compliance from test existence alone.
2. **Plan decisions alignment**: Do technical decisions in `plan.md` contradict any principle?
3. **Severity**: Any violation of a MUST / MUST NOT principle is automatically **CRITICAL**. Missing test coverage for a principle is at least **MEDIUM**.

Output a table:

| Principle ID | Statement (summary) | AC + Test Coverage | Code Compliance | Status |
|---|---|---|---|---|

#### B4. Example Mapping Coverage
- Does every rule in example-mapping have a corresponding scenario?
- Are all questions resolved?

#### B5. UI Contract Consistency (if CONTRACTS exist)
- Do component names in `contracts/ui/` match spec and tasks?
- Are props, routes, and enhanced components consistent with plan.md architecture?
- Report terminology drift

## Pass C: Detection Scan

#### Duplication Detection
- Similar ACs testing the same behavior? Redundant tests?

#### Ambiguity Detection
- Vague AC descriptions? Unclear test names?

#### Under-specification
- ACs missing validation conditions? Tests missing assertions?

#### Implementation Leakage
- ACs describing HOW instead of WHAT? Business requirements using technical terms?

## Pass D: Requirements Quality Validation

> Integrates the requirements quality checks formerly in `/speckit.checklist`.

#### Completeness
- Are all necessary requirements documented?
- Does each failure mode define error handling requirements?
- Are accessibility requirements specified?

#### Clarity
- Are requirements specific and unambiguous?
- Are vague terms quantified with concrete criteria?
- Are success metrics measurable?

#### Consistency
- Are requirements free of mutual conflicts?
- Are patterns consistent within the feature?

#### Coverage
- Are all scenarios/edge cases covered?
- Are boundary conditions defined?
- Are negative paths specified?

#### Compliance Coverage

> Deep design compliance (A11y, AI Risk, Design System) has moved to `/speckit.validate` Pass 5. Review only checks requirements-level compliance coverage.

- Do all compliance-related requirements have corresponding ACs?
- Do ACs cover compliance boundary conditions?

## Pass E: Traceability Matrix

Build behavior-to-implementation traceability:

| AC | Rule | Action(s) | Test | Status |
|----|------|-----------|------|--------|
| AC-001 | Rule 1 | S012-S015 | login.test.ts | [Pass/Fail/Pending] |

Flag gaps: ACs without actions, actions without ACs, actions without tests, rules without examples.

## Pass F: Living Document

Generate `SPEC_DIR/checklists/feature-readiness.md` per the format in `skills/speckit/references/review-report-format.md`.

---

## Severity Levels

- **CRITICAL**: Principle violation, P1 scenario coverage gap, requirements quality < 60%
- **HIGH**: Duplicate scenarios, ambiguous requirements, P2 coverage gap
- **MEDIUM**: Terminology drift, minor coverage gap, unclear step
- **LOW**: Style improvement, optimization opportunity

## Feature Readiness Gate

| Gate | Criteria | Blocking? |
|------|----------|-----------|
| Requirements Quality | Each dimension > 80% | Yes |
| Happy Path Coverage | P1 stories 100% | Yes |
| Negative Coverage | At least 1 per story | Yes |
| Principles Coverage | At least 1 boundary | Yes |
| Traceability | All scenarios linked to actions | No |
| Open Issues | No CRITICAL/HIGH | Yes |

## Next Steps

Based on findings:
- CRITICAL: Must resolve before continuing -> recommend `/speckit.plan update`
- HIGH: Should address to improve quality -> recommend specific fixes
- LOW/MEDIUM only: May proceed -> recommend `/speckit.validate` (deep validation) or commit + merge

### When task ends with no fixes needed (mandatory)

When **Readiness: Ready** and **no CRITICAL/HIGH outstanding**:

1. **Show current branch**: Run `git rev-parse --abbrev-ref HEAD` and display in the report
2. **Branch guard**: If current branch is `main` or `master`, **stop the merge flow** and warn:
   ```
   WARNING: Currently on main branch. Do not commit directly. Create a feature branch first.
   ```
3. If branch is correct, append to report:

```
Review passed. Current branch: `<branch-name>`

[A] /speckit.validate — Deep validation (security, architecture, code quality, design compliance, BDD output)
[B] commit + merge `<branch-name>` -> main
```

## Pass G: Goal Alignment (always enabled)

| Check | Method |
|-------|--------|
| Product goal coverage | Does each goal in `context.md` Business Goals have a corresponding implementation? |
| Milestone consistency | Do `plan.md` Phase Deliverables match actual output? |
| Excess implementation | Are there features implemented that are not in goals or milestones? |

> **Deep quality validation (security/architecture/code/design/BDD) has moved to `/speckit.validate`**. Review focuses on behavior coverage and readiness gates.

## Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: review
- **Last**: review — Readiness: [Ready/Not Ready], [N] critical, [N] high
- **Next**: [/speckit.validate | /speckit.plan update | commit + merge]
- Include: path to feature-readiness.md, executive summary (2-3 sentences), findings count, readiness status

## Analysis Guidelines

- **Behavior over implementation**: "User sees confirmation" (good) vs "API returns 200" (bad)
- **Professional tone**: "Consider adding coverage for..." not "You forgot to..."
- **Coverage targets**: P1 Happy Path 100%, P1 Negative 50%+, Principles 100%, Overall 80%+

## Operating Principles

> Common rules: see `speckit/references/command-shared`.

- Read-only — never modify files
- Never speculate — report only actual findings
- Principles violations are always CRITICAL
- Every finding includes a recommendation
- Cite exact file locations
