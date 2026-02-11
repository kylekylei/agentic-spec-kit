---
description: Perform a professional, neutral behavioral coverage analysis across spec, plan, tasks, and .feature files.
handoffs:
  - label: Run Checklist
    agent: teammate.checklist
    prompt: Generate Living Documentation and verify feature readiness
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Perform a **professional, neutral** analysis of behavioral coverage and artifact consistency. This review is suitable for team collaboration and enterprise environments.

### Operating Constraints

**STRICTLY READ-ONLY**: Do **not** modify any files. Output a structured analysis report.

**Principles Authority**: The project principles (`.teammate/memory/principles.md`) are **non-negotiable**. Principles conflicts are automatically CRITICAL.

**Professional Tone**: This analysis uses objective, constructive language suitable for team review. No sarcasm, criticism, or inflammatory language.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Execution Steps

1. **Initialize Analysis Context**:

   Run `.teammate/scripts/bash/check-prerequisites.sh --json --require-actions --include-actions` from repo root and parse:
   - `FEATURE_DIR`
   - `AVAILABLE_DOCS`
   
   Derive paths:
   - SPEC = `FEATURE_DIR/spec.md`
   - TASKS = `FEATURE_DIR/tasks.md`
   - ACTIONS = `FEATURE_DIR/actions.md`
   - FEATURES = `FEATURE_DIR/scenarios/*.feature`
   - EXAMPLE_MAPPING = `FEATURE_DIR/example-mapping.md`
   - SCREENPLAY = `FEATURE_DIR/screenplay.md`
   - CONTRACTS = `FEATURE_DIR/contracts/ui/*.md` (if directory exists)
   
   Abort if required files missing.

2. **Load Artifacts**:

   From spec.md:
   - User stories and priorities
   - Functional requirements
   - Success criteria

   From tasks.md:
   - Architecture decisions
   - Technical constraints

   From actions.md:
   - Actions with [Verifies: @tag] markers
   - Phase structure

   From scenarios/*.feature:
   - All scenarios with tags
   - Step definitions
   - Tag distribution

   From principles:
   - Principles and boundaries

3. **Build Semantic Models**:

   - **Requirements inventory**: Map each requirement to a key
   - **Scenario inventory**: All scenarios with tags and status
   - **Action coverage mapping**: Map actions to scenarios via [Verifies: @tag]
   - **Principles rule set**: MUST/MUST NOT statements

4. **Behavioral Coverage Analysis**:

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
   |-------|-----------|-------|----------|--------------|--------|
   | US1 | [N] | [N] | [N] | [N] | [Complete/Gaps] |

   #### Behavior Quality Checks
   
   - Are scenarios testing BEHAVIOR (what) or IMPLEMENTATION (how)?
   - Are steps declarative or imperative?
   - Are scenarios independent (can run in isolation)?

5. **Consistency Analysis**:

   #### A. Traceability Verification
   
   - Every requirement should have scenarios
   - Every scenario should have actions
   - Every action should have [Verifies: @tag]
   
   Report gaps:
   - Requirements without scenarios
   - Scenarios without actions
   - Actions without scenario links

   #### B. Terminology Consistency
   
   - Same concepts named differently across files?
   - Entity names match between spec, model, and scenarios?

   #### C. Principles Alignment
   
   - Every MUST NOT has a @principles scenario?
   - Plan decisions align with principles?

   #### D. Example Mapping Coverage
   
   - Every rule from example-mapping has scenarios?
   - Questions all resolved?

   #### E. UI Contract Consistency (if CONTRACTS exist)
   
   - Component names in `contracts/ui/` match spec acceptance criteria and tasks component list?
   - Component descriptions align with actual implementation (no stale names or outdated descriptions)?
   - Props, routes, and enhanced components match tasks.md architecture?
   - Report any terminology drift between contracts and other artifacts (e.g. old component name vs renamed component)

6. **Detection Passes**:

   #### Duplication Detection
   - Similar scenarios testing same behavior?
   - Redundant step definitions?

   #### Ambiguity Detection
   - Vague scenario names?
   - Unclear step language?

   #### Underspecification
   - Scenarios missing Then assertions?
   - Steps with unclear outcomes?

   #### Implementation Leakage
   - Scenarios that describe HOW instead of WHAT?
   - Technical terms in business scenarios?

7. **Severity Assignment**:

   - **CRITICAL**: Principles violations, missing coverage for P1 scenarios
   - **HIGH**: Duplicate scenarios, ambiguous requirements, P2 coverage gaps
   - **MEDIUM**: Terminology drift, minor coverage gaps, unclear steps
   - **LOW**: Style improvements, optimization opportunities

8. **Produce Analysis Report**:

   ```markdown
   # Behavioral Coverage Analysis Report
   
   **Feature**: [Name]
   **Analyzed**: [Date]
   **Status**: [Healthy/Needs Attention/Critical Issues]
   
   ## Executive Summary
   
   [2-3 sentence overview of findings]
   
   ## Behavioral Coverage
   
   ### Scenario Distribution
   [Table from step 4]
   
   ### Coverage by Story
   [Table from step 4]
   
   ## Findings
   
   | ID | Category | Severity | Location | Finding | Recommendation |
   |----|----------|----------|----------|---------|----------------|
   
   ## Traceability Summary
   
   | Requirement | Scenarios | Actions | Status |
   |-------------|-----------|---------|--------|
   
   ## Principles Compliance
   
   | Principle | Coverage | Status |
   |-----------|----------|--------|
   
   ## Metrics
   
   - Total Scenarios: [N]
   - Total Actions: [N]
   - Scenario Coverage: [%]
   - Principles Coverage: [%]
   - Critical Issues: [N]
   - High Issues: [N]
   
   ## Recommendations
   
   [Prioritized list of actions]
   ```

9. **Provide Next Actions**:

   Based on findings:
   - If CRITICAL: Must resolve before proceeding
   - If HIGH: Should address for quality
   - If only LOW/MEDIUM: Can proceed with notes
   
   Suggest specific commands:
   - "Add @negative scenario for [requirement] using `/teammate.plan`"
   - "Add principles boundary scenario for [principle]"

10. **Update Active Context**（Memory Delta Protocol）:

   Update `.teammate/memory/active-context.md` using delta mode:
   - **覆寫 `## Current State`**：Phase: Deliver, Last Command: review, Next Action: [recommended command from step 9]
   - **追加 `## Session Log`**：`| [timestamp] | review | [N] critical, [N] high findings | [recommended action] |`
   - **更新 `## Blockers`**：如有 CRITICAL findings，記錄為 blocker

## Analysis Guidelines

### Behavior vs Implementation

**Good (Behavior)**:
- "User sees confirmation message"
- "Order is placed successfully"
- "System rejects invalid input"

**Bad (Implementation)**:
- "API returns 200 status"
- "Database record is created"
- "Redis cache is updated"

### Professional Language

**Use**:
- "This scenario could be enhanced with..."
- "Consider adding coverage for..."
- "A gap exists in..."

**Avoid**:
- "This is wrong"
- "You forgot to..."
- "Obviously missing..."

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
