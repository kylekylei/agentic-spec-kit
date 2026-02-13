# Example Mapping: [FEATURE_NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft | Ready for Formulation | Complete
**Spec Reference**: [Link to spec.md]

---

## Story

> The user story being analyzed

**As a** [ACTOR/PERSONA]
**I want** [CAPABILITY/ACTION]
**So that** [BUSINESS_VALUE/BENEFIT]

**Story ID**: [US-###]
**Priority**: P[1-3]

---

## Rules

> Business rules that govern this story. Each rule becomes one or more scenarios.

### Rule 1: [RULE_NAME]

**Statement**: [Clear, testable rule statement]

**Examples**:

| # | Given (Context) | When (Action) | Then (Outcome) | Type |
|---|-----------------|---------------|----------------|------|
| 1.1 | [Initial state] | [User action] | [Expected result] | Happy |
| 1.2 | [Alternative context] | [Same/similar action] | [Different result] | Alternative |
| 1.3 | [Error context] | [Invalid action] | [Error handling] | Negative |

**Edge Cases**:
- [ ] [Boundary condition to consider]
- [ ] [Limit or threshold case]

---

### Rule 2: [RULE_NAME]

**Statement**: [Clear, testable rule statement]

**Examples**:

| # | Given (Context) | When (Action) | Then (Outcome) | Type |
|---|-----------------|---------------|----------------|------|
| 2.1 | [Initial state] | [User action] | [Expected result] | Happy |
| 2.2 | [Context] | [Action] | [Result] | [Type] |

**Edge Cases**:
- [ ] [Edge case to consider]

---

### Rule 3: [RULE_NAME]

**Statement**: [Clear, testable rule statement]

**Examples**:

| # | Given (Context) | When (Action) | Then (Outcome) | Type |
|---|-----------------|---------------|----------------|------|
| 3.1 | [Initial state] | [User action] | [Expected result] | Happy |

---

## Questions

> Unresolved questions that need answers before proceeding to Gherkin

| # | Question | Impact | Status | Answer |
|---|----------|--------|--------|--------|
| Q1 | [Question about unclear requirement] | [High/Medium/Low] | Open/Resolved | [Answer when resolved] |
| Q2 | [Question about edge case] | [Impact] | Open/Resolved | [Answer] |
| Q3 | [Question about business rule] | [Impact] | Open/Resolved | [Answer] |

---

## Principles Boundaries

> Rules from principles.md that apply to this story

| Principle | Constraint | How It Applies |
|-----------|------------|----------------|
| [PRINCIPLE_NAME] | [MUST/MUST NOT statement] | [How this affects the story] |

---

## Readiness Checklist

- [ ] All rules identified and documented
- [ ] Each rule has at least one happy path example
- [ ] Negative/error cases identified for each rule
- [ ] All high-impact questions resolved
- [ ] principles boundaries identified
- [ ] Edge cases documented
- [ ] Ready for `/teammate.plan` (Gherkin generation)

## Readiness Score

| Metric | Count | Target |
|--------|-------|--------|
| Rules Defined | [N] | 3+ |
| Examples per Rule | [Avg] | 2+ |
| Questions Open | [N] | 0 |
| Edge Cases Documented | [N] | Per rule |

**Status**: [ ] Not Ready | [ ] Partially Ready | [ ] Ready for Formulation

---

## Next Steps

1. [ ] Resolve open questions with stakeholders
2. [ ] Run `/teammate.plan` to generate Gherkin scenarios
3. [ ] Review generated `.feature` file for completeness

---

**Session Date**: [DATE]
**Participants**: [Names or AI]
