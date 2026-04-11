---
description: Engineering retrospective — aggregate .specify/ insights, analyze task patterns, detect recurring issues, produce retro report.
handoffs:
  - label: Start next feature
    agent: speckit.align
    prompt: Apply retro learnings to next feature alignment
    send: true
---

## User Input

```text
$ARGUMENTS
```

| Argument | Behavior |
|----------|----------|
| _(empty)_ | Analyze all .specify/ data |
| `--task NNN` | Single task retrospective |
| `--since YYYY-MM-DD` | Activity since date |
| `--cross-system` | Include experience-kit + spec-ops feedback |

---

## Overview

Engineering retrospective that aggregates `.specify/` data to identify patterns, recurring issues, and process improvements. Feeds back into spec-ops calibration.

---

## Phase 1: Data Collection

Scan `.specify/` and related directories:

| Source | Path | Extract |
| --- | --- | --- |
| Task insights | `SPEC_DIR/insights.md` | Per-action findings, trade-offs |
| Task history | `.specify/tasks/` | Completed tasks, duration, iterations |
| Review reports | `SPEC_DIR/checklists/feature-readiness.md` | Review findings |
| Validate reports | Validate output | Quality findings |
| QA reports | `SPEC_DIR/checklists/qa-report.md` | Test results, a11y issues |
| Plan accuracy | `SPEC_DIR/plan.md` | Planned vs actual actions |

### Cross-system data (if `--cross-system`)

| Source | Path | Extract |
| --- | --- | --- |
| experience-kit audit | `design/audit/reports/*.md` | Design compliance trends |
| spec-ops contract | `specs/*/reviews/*-spec-contract-v*.json` | Spec quality scores |

---

## Phase 2: Task Pattern Analysis

### 2a. Execution Metrics

| Metric | Calculation | Healthy Range |
| --- | --- | --- |
| Plan accuracy | Completed actions / planned actions | ≥ 85% |
| Iteration rate | Actions revised after GREEN / total actions | ≤ 10% |
| Verify skip rate | `- [~]` actions / total actions | 0% (ideal) |
| Average actions per story | Total actions / total stories | 3-8 |

### 2b. Issue Classification

Classify all findings from review + validate + QA:

| Category | Count | Trend | Top Issue |
| --- | --- | --- | --- |
| Security | N | ↑/↓/→ | [description] |
| Architecture | N | | |
| Code Quality | N | | |
| Testing | N | | |
| Design/A11y | N | | |

### 2c. Recurring Issues

Detect patterns across tasks:
- Same finding category appearing in ≥ 3 tasks → systemic issue
- Same file/module appearing in ≥ 3 findings → hotspot

---

## Phase 3: Insights Health

### 3a. Insight Usage

| Metric | Value |
| --- | --- |
| Total insights recorded | N |
| Insights referenced in subsequent tasks | N |
| Stale insights (> 30 days unreferenced) | [list] |

### 3b. Principle Candidates

Insights referenced ≥ 3 times across tasks → suggest graduation to `principles.md`:

| Insight | References | Suggested Principle |
| --- | --- | --- |
| [insight text] | N | MUST / SHOULD [rule] |

---

## Phase 4: Process Improvement

### 4a. Bottleneck Analysis

| Phase | Avg Duration | Issues Found | Bottleneck? |
| --- | --- | --- | --- |
| align | — | N | |
| plan | — | N | |
| execute | — | N | |
| review | — | N | |
| validate | — | N | |
| qa | — | N | |

### 4b. spec-ops Feedback (if --cross-system)

> Feeds back to spec-ops spec-retro for calibration

Generate `{product}-engineering-feedback-v{N}.md` in unified feedback format (spec-ops `spec-retro` calibration input C):

```markdown
---
product: {product}
feedback_version: v{N}
source_system: spec-kit
produced_at: YYYY-MM-DD
aligned_spec_contract: v{N}
---

## spec-kit Engineering Feedback

### Spec Quality Signals
- clarification_questions: {{count}} (time-to-first-clarification: {{duration}})
- spec_coverage_ratio: {{%}} (ACs fully covered by spec)
- ambiguity_findings: [list of ambiguous requirements found during execute]

### Implementation Signals
- iteration_rate: {{%}}
- verify_skip_rate: {{%}}
- principle_violations: {{count}}

### AC Seed Delta
- ac_seed_modified: [list of scenario IDs modified from experience-kit AC Seed]
- ac_seed_conflicts: [list of conflicts with spec-contract Required sub-chars, with resolution]

### Own/Enable AC Summary
- own_ac_count: {{N}} (AC-NNN)
- enable_ac_count: {{N}} (AC-E-NNN)
- enable_ac_pass_rate: {{%}}
```

Output path: `.specify/reports/{product}-engineering-feedback-v{N}.md`

This file is consumed by spec-ops `spec-retro` as calibration input C (alongside A=QA feedback, B=design feedback).

---

## Phase 5: Retro Report

Generate `SPEC_DIR/checklists/retro-report.md`:

```markdown
## Engineering Retrospective Report
Date: {{date}}
Scope: {{task range or date range}}

### Summary
- Tasks completed: {{n}}
- Plan accuracy: {{%}}
- Recurring issues: {{n}} systemic
- Insights: {{n}} total, {{n}} candidates for principles

### What Went Well
[auto-detected from GREEN actions, positive validate findings]

### What Needs Improvement
[auto-detected from recurring issues, high iteration rate, bottlenecks]

### Action Items
| # | Type | Action | Priority |
| 1 | Process | [improvement] | P1 |
| 2 | Principle | Graduate insight → principles.md | P2 |
| 3 | Cleanup | Remove stale insights | P3 |
```

---

## Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: retro
- **Last**: retro — [N] tasks analyzed, [N] action items
- **Next**: /speckit.align (next feature) | apply action items

## Operating Principles

> Common rules: see `speckit/references/command-shared`.

- Read-only — never modify source code
- Objective analysis — data-driven, not opinion-based
- Cross-system feedback uses structured format for machine consumption
- Action items are suggestions, not mandates
