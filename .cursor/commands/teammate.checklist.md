---
description: Generate Living Documentation and Feature Readiness reports by validating requirements quality and behavior coverage.
handoffs:
  - label: Create Issues
    agent: teammate.assign
    prompt: Convert tasks to GitHub issues
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Validate requirements quality ("Unit Tests for English") and generate **Living Documentation** that proves feature readiness. This is the final verification gate in the Teammate lifecycle.

### Core Concept: "Unit Tests for Requirements"

**CRITICAL**: Checklists validate the QUALITY of requirements, not the implementation.

**NOT for verification/testing**:
- "Verify the button clicks correctly"
- "Test error handling works"
- "Confirm the API returns 200"

**FOR requirements quality validation**:
- "Are visual hierarchy requirements defined for all card types?"
- "Is 'prominent display' quantified with specific sizing/positioning?"
- "Are accessibility requirements specified for all interactive elements?"

### Execution Steps

1. **Setup**: Run `.teammate/scripts/bash/check-prerequisites.sh --json` from repo root. Parse JSON for:
   - `FEATURE_DIR`
   - `AVAILABLE_DOCS`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Load Feature Context**:

   Required:
   - `spec.md` - Feature requirements
   - `scenarios/*.feature` - Gherkin scenarios
   
   Optional:
   - `example-mapping.md` - Rules and examples
   - `screenplay.md` - Actors and tasks
   - `actions.md` - Implementation actions
   - `tasks.md` - Technical plan
   - `.teammate/memory/principles.md` - Principles

3. **Clarify Intent** (if needed):

   Generate up to 3 contextual questions based on:
   - Feature domain keywords
   - Risk indicators
   - Stakeholder hints
   
   Question types:
   - Scope refinement
   - Risk prioritization
   - Depth calibration
   - Audience framing

4. **Phase 1: Requirements Quality Validation**

   Generate checklist items that test REQUIREMENTS quality:

   #### Completeness
   - Are all necessary requirements documented?
   - Are error handling requirements defined for all failure modes?
   - Are accessibility requirements specified?

   #### Clarity
   - Are requirements specific and unambiguous?
   - Is [vague term] quantified with specific criteria?
   - Are success metrics measurable?

   #### Consistency
   - Do requirements align without conflicts?
   - Are patterns consistent across the feature?

   #### Coverage
   - Are all scenarios/edge cases addressed?
   - Are boundary conditions defined?
   - Are negative paths specified?

   #### Principles Alignment
   - Are principles boundaries documented?
   - Are there scenarios that verify principle enforcement?

5. **Phase 2: Behavior Coverage Analysis**

   Analyze `.feature` files for behavioral completeness:

   | Story | Scenarios | Happy | Negative | Boundary | Principles |
   |-------|-----------|-------|----------|----------|--------------|
   | US1   | [N]       | [N]   | [N]      | [N]      | [N]          |
   | US2   | [N]       | [N]   | [N]      | [N]      | [N]          |

   Coverage metrics:
   - Total scenarios
   - Scenarios per story
   - Tag distribution (@happy-path, @negative, etc.)
   - Principles boundary coverage

6. **Phase 3: Traceability Matrix**

   Build traceability from behaviors to implementation:

   | Scenario | Rule | Action(s) | Status |
   |----------|------|-----------|--------|
   | @us1-login-success | Rule 1 | S012-S015 | [Pass/Fail/Pending] |
   | @us1-login-failure | Rule 2 | S016 | [Pass/Fail/Pending] |

   Identify gaps:
   - Scenarios without linked actions
   - Actions without linked scenarios
   - Rules without examples

7. **Phase 4: Generate Living Documentation**

   Create `FEATURE_DIR/checklists/feature-readiness.md`:

   ```markdown
   # Feature Readiness Report: [Feature Name]
   
   **Generated**: [Date]
   **Status**: [Ready/Not Ready/Partial]
   
   ## Executive Summary
   
   [Brief status overview]
   
   ## Requirements Quality
   
   | Dimension | Score | Issues |
   |-----------|-------|--------|
   | Completeness | [%] | [N] |
   | Clarity | [%] | [N] |
   | Consistency | [%] | [N] |
   | Coverage | [%] | [N] |
   
   ## Behavior Coverage
   
   | Metric | Count | Target | Status |
   |--------|-------|--------|--------|
   | Total Scenarios | [N] | - | - |
   | Happy Path | [N] | 1+ per story | [Pass/Fail] |
   | Negative Path | [N] | 1+ per story | [Pass/Fail] |
   | Principles | [N] | 1+ | [Pass/Fail] |
   
   ## Traceability
   
   [Matrix showing scenario ??action ??implementation status]
   
   ## Open Issues
   
   [List of unresolved items by severity]
   
   ## Recommendation
   
   [Ready to proceed / Needs attention / Blocked]
   ```

8. **Phase 5: Generate Domain Checklist** (if requested)

   Create domain-specific checklist in `FEATURE_DIR/checklists/[domain].md`:
   
   Follow template in `.teammate/templates/checklist-template.md`:
   - Use CHK### numbering
   - Group by quality dimension
   - Include traceability references [Spec §X.Y] or [Gap]
   - 80%+ items must have references

9. **Update Progress**:

   Update `.teammate/memory/progress.md`:
   - Feature verification status
   - Coverage metrics
   - Readiness assessment

10. **Update Active Context**（Memory Delta Protocol）:

    Update `.teammate/memory/active-context.md` using delta mode:
    - **覆寫 `## Current State`**：Phase: Deliver, Last Command: checklist, Next Action: /teammate.assign
    - **追加 `## Session Log`**：`| [timestamp] | checklist | Readiness: [READY/NOT READY], [pass/total] checks | [blockers if any] |`

11. **Report Completion**:

    Output:
    - Path to generated reports
    - Requirements quality score
    - Behavior coverage summary
    - Traceability gaps
    - Overall readiness status
    - Recommended next steps
    - Suggested next command: `/teammate.assign`

## Checklist Item Writing Guide

### Correct Pattern (Tests Requirements)
```markdown
- [ ] CHK001 Are error handling requirements defined for all API failure modes? [Completeness]
- [ ] CHK002 Is 'fast loading' quantified with specific timing thresholds? [Clarity, Spec §NFR-2]
- [ ] CHK003 Are navigation requirements consistent across all pages? [Consistency]
- [ ] CHK004 Are requirements defined for zero-state scenarios? [Coverage, Gap]
```

### Wrong Pattern (Tests Implementation)
```markdown
- [ ] CHK001 Verify landing page displays 3 cards
- [ ] CHK002 Test hover states work correctly
- [ ] CHK003 Confirm API returns 200
```

## Living Documentation Standards

Living Documentation must:
1. Be auto-generated from .feature files and test results
2. Show current state of all behaviors
3. Provide traceability from requirement to implementation
4. Be readable by non-technical stakeholders
5. Update automatically as scenarios pass/fail

## Feature Readiness Gates

| Gate | Criteria | Blocking? |
|------|----------|-----------|
| Requirements Quality | All dimensions > 80% | Yes |
| Happy Path Coverage | 100% of P1 stories | Yes |
| Negative Coverage | At least 1 per story | Yes |
| Principles Coverage | At least 1 boundary | Yes |
| Traceability | All scenarios linked to actions | No |
| Open Issues | No critical/high issues | Yes |
