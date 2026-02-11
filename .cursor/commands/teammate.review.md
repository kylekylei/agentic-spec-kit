---
description: Perform behavioral coverage analysis and feature readiness validation. Combines review + checklist into one comprehensive quality gate.
handoffs:
  - label: Create Issues
    agent: teammate.assign
    prompt: Convert tasks to GitHub issues
    send: true
  - label: Fix Gaps
    agent: teammate.plan
    prompt: Update plan to address review findings
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Perform a **professional, neutral** analysis of behavioral coverage, artifact consistency, and feature readiness. This is the final verification gate — combining behavioral review and requirements quality validation into one pass.

### Operating Constraints

**STRICTLY READ-ONLY**: Do **not** modify any files. Output a structured analysis report.

**Principles Authority**: The project principles (`.teammate/memory/principles.md`) are **non-negotiable**. Principles conflicts are automatically CRITICAL.

**Professional Tone**: Objective, constructive language suitable for team review. No sarcasm or inflammatory language.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Setup

Run `.teammate/scripts/bash/check-prerequisites.sh --json --require-actions --include-actions` from repo root and parse:
- `FEATURE_DIR`, `AVAILABLE_DOCS`

Derive paths:
- SPEC = `FEATURE_DIR/spec.md`
- TASKS = `FEATURE_DIR/tasks.md`
- ACTIONS = `FEATURE_DIR/actions.md`
- FEATURES = `FEATURE_DIR/scenarios/*.feature`
- EXAMPLE_MAPPING = `FEATURE_DIR/example-mapping.md`
- SCREENPLAY = `FEATURE_DIR/screenplay.md`
- CONTRACTS = `FEATURE_DIR/contracts/ui/*.md` (if directory exists)
- INSIGHTS = `FEATURE_DIR/insights.md` (if exists)

Abort if required files missing.

### Load Artifacts

From spec.md: User stories, functional requirements, success criteria
From tasks.md: Architecture decisions, technical constraints
From actions.md: Actions with [Verifies: @tag] markers, phase structure
From scenarios/*.feature: All scenarios with tags, step definitions
From principles: Principles and boundaries

---

## Pass A: Behavioral Coverage Analysis

#### Scenario Type Distribution

| Type | Count | Percentage | Target |
|------|-------|------------|--------|
| @happy-path | [N] | [%] | 30-40% |
| @alternative | [N] | [%] | 20-30% |
| @negative | [N] | [%] | 20-30% |
| @boundary | [N] | [%] | 10-15% |
| @principles | [N] | [%] | 5-10% |

#### Coverage by User Story

| Story | Scenarios | Happy | Negative | Principles | Status |
|-------|-----------|-------|----------|------------|--------|
| US1 | [N] | [N] | [N] | [N] | [Complete/Gaps] |

#### Behavior Quality Checks

- Are scenarios testing BEHAVIOR (what) or IMPLEMENTATION (how)?
- Are steps declarative or imperative?
- Are scenarios independent (can run in isolation)?

## Pass B: Consistency Analysis

#### B1. Traceability Verification
- Every requirement → scenarios → actions → [Verifies: @tag]
- Report gaps: requirements without scenarios, scenarios without actions, orphan actions

#### B2. Terminology Consistency
- Same concepts named differently across files?
- Entity names match between spec, model, and scenarios?

#### B3. Principles Alignment
- Every MUST NOT has a @principles scenario?
- Plan decisions align with principles?

#### B4. Example Mapping Coverage
- Every rule from example-mapping has scenarios?
- Questions all resolved?

#### B5. UI Contract Consistency (if CONTRACTS exist)
- Component names in `contracts/ui/` match spec and tasks?
- Props, routes, and enhanced components match tasks.md?
- Report terminology drift

## Pass C: Detection Passes

#### Duplication Detection
- Similar scenarios testing same behavior? Redundant step definitions?

#### Ambiguity Detection
- Vague scenario names? Unclear step language?

#### Underspecification
- Scenarios missing Then assertions? Steps with unclear outcomes?

#### Implementation Leakage
- Scenarios that describe HOW instead of WHAT? Technical terms in business scenarios?

## Pass D: Requirements Quality Validation

> 整合原 `/teammate.checklist` 的需求品質檢核功能。

#### Completeness
- Are all necessary requirements documented?
- Are error handling requirements defined for all failure modes?
- Are accessibility requirements specified?

#### Clarity
- Are requirements specific and unambiguous?
- Are vague terms quantified with specific criteria?
- Are success metrics measurable?

#### Consistency
- Do requirements align without conflicts?
- Are patterns consistent across the feature?

#### Coverage
- Are all scenarios/edge cases addressed?
- Are boundary conditions defined?
- Are negative paths specified?

## Pass E: Traceability Matrix

Build traceability from behaviors to implementation:

| Scenario | Rule | Action(s) | Status |
|----------|------|-----------|--------|
| @us1-login-success | Rule 1 | S012-S015 | [Pass/Fail/Pending] |

Identify gaps: Scenarios without actions, actions without scenarios, rules without examples.

## Pass F: Living Documentation

Generate `FEATURE_DIR/checklists/feature-readiness.md`:

```markdown
# Feature Readiness Report: [Feature Name]

**Generated**: [Date]
**Status**: [Ready/Not Ready/Partial]

## Executive Summary
[2-3 sentence overview]

## Behavioral Coverage
[Scenario distribution + coverage by story]

## Requirements Quality
| Dimension | Score | Issues |
|-----------|-------|--------|
| Completeness | [%] | [N] |
| Clarity | [%] | [N] |
| Consistency | [%] | [N] |
| Coverage | [%] | [N] |

## Findings
| ID | Category | Severity | Location | Finding | Recommendation |
|----|----------|----------|----------|---------|----------------|

## Traceability Summary
[Matrix from Pass E]

## Principles Compliance
| Principle | Coverage | Status |
|-----------|----------|--------|

## Metrics
- Total Scenarios: [N]
- Total Actions: [N]
- Scenario Coverage: [%]
- Principles Coverage: [%]
- Critical Issues: [N]

## Recommendation
[Ready to proceed / Needs attention / Blocked]
```

---

## Severity Assignment

- **CRITICAL**: Principles violations, missing coverage for P1 scenarios, requirements quality < 60%
- **HIGH**: Duplicate scenarios, ambiguous requirements, P2 coverage gaps
- **MEDIUM**: Terminology drift, minor coverage gaps, unclear steps
- **LOW**: Style improvements, optimization opportunities

## Feature Readiness Gates

| Gate | Criteria | Blocking? |
|------|----------|-----------|
| Requirements Quality | All dimensions > 80% | Yes |
| Happy Path Coverage | 100% of P1 stories | Yes |
| Negative Coverage | At least 1 per story | Yes |
| Principles Coverage | At least 1 boundary | Yes |
| Traceability | All scenarios linked to actions | No |
| Open Issues | No critical/high issues | Yes |

## Next Actions

Based on findings:
- If CRITICAL: Must resolve before proceeding → suggest `/teammate.plan update`
- If HIGH: Should address for quality → suggest specific fixes
- If only LOW/MEDIUM: Can proceed → suggest `/teammate.assign`

## Update Progress

Update `.teammate/memory/progress.md`: Feature verification status, coverage metrics, readiness assessment.

## Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/active-context.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Deliver, Last Command: review, Next Action: [recommended command]
- **追加 `## Session Log`**：`| [timestamp] | review | [N] critical, [N] high, Readiness: [status] | [recommendation] |`
- **更新 `## Blockers`**：如有 CRITICAL findings，記錄為 blocker

## Report Completion

Output:
- Path to `feature-readiness.md`
- Executive summary (2-3 sentences)
- Critical/High findings count
- Readiness status
- Recommended next steps
- Suggested next command

## Analysis Guidelines

### Behavior vs Implementation

**Good**: "User sees confirmation message", "Order is placed successfully"
**Bad**: "API returns 200 status", "Database record is created"

### Professional Language

**Use**: "This scenario could be enhanced with...", "Consider adding coverage for..."
**Avoid**: "This is wrong", "You forgot to..."

### Coverage Targets

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| P1 Happy Path | 100% | 100% |
| P1 Negative | 50%+ | 25% |
| Principles | 100% | 80% |
| Overall | 80%+ | 60% |

## Operating Principles

- **NEVER modify files** (read-only analysis)
- **NEVER hallucinate** (report only what's found)
- **Prioritize principles** (violations are always CRITICAL)
- **Be constructive** (every finding has a recommendation)
- **Be specific** (cite exact locations and issues)
