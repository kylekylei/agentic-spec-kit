---
description: Create or update the project principles (non-negotiable behavioral boundaries) ensuring all dependent templates stay in sync.
handoffs: 
  - label: Start Alignment
    agent: teammate.align
    prompt: Principles are defined. Let's align on the first feature. I want to build...
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

You are updating the project principles at `.teammate/memory/principles.md`. This file defines the **non-negotiable behavioral principles** that the system must NEVER violate. It serves as the foundation for all behavior specifications.

### Principles Purpose

The principles file defines:
1. **Behavioral Boundaries** - What the system MUST do
2. **Negative Prompting** - What the system MUST NEVER do
3. **Invariants** - Conditions that must always hold true
4. **Governance** - How principles can be amended

### Execution Flow

1. **Load & Snapshot**
   
   Load the existing principles at `.teammate/memory/principles.md`.
   
   **Pre-Update Snapshot** (auto, not first run):
   - Scan for placeholder tokens (`[ALL_CAPS_IDENTIFIER]`)
   - If **no placeholders found** (= file was already initialized):
     1. Copy current file to `.teammate/snapshots/principles-YYYY-MM-DD.md`
     2. Ask user: "What is the reason for this change?" (one line)
     3. Prepend the reason as a comment header in the snapshot file:
        ```
        <!-- Snapshot: YYYY-MM-DD | Reason: [user's reason] -->
        ```
   - If **placeholders found** (= first run or template): skip snapshot, proceed normally.
   
   Then:
   - Identify every placeholder token of the form `[ALL_CAPS_IDENTIFIER]`
   - The user might require fewer or more principles than the template
   - Adjust the document structure accordingly

2. **Collect/Derive Values for Placeholders**:
   
   - If user input supplies a value, use it
   - Otherwise infer from existing repo context (README, docs, prior versions)
   - For governance dates:
     - `RATIFICATION_DATE` is the original adoption date
     - `LAST_AMENDED_DATE` is today if changes are made
   - `PRINCIPLES_VERSION` must increment according to semantic versioning:
     - MAJOR: Backward incompatible governance/principle removals or redefinitions
     - MINOR: New principle/section added or materially expanded guidance
     - PATCH: Clarifications, wording, typo fixes, non-semantic refinements

3. **Draft Updated Principles Content**:

   Structure the principles file with these sections:

   #### Core Principles (Behavioral Boundaries)
   
   For each principle:
   - **Name**: Clear, memorable identifier
   - **MUST Statements**: What the system MUST do
   - **MUST NOT Statements**: What the system MUST NEVER do (Negative Prompting)
   - **Rationale**: Why this principle exists
   - **Verification**: How to verify compliance

   Example:
   ```markdown
   ### I. Data Integrity
   
   **MUST**:
   - Validate all user input before processing
   - Persist data only after successful validation
   - Log all data modification events
   
   **MUST NOT** (Negative Prompting):
   - Accept unvalidated external input
   - Modify data without audit trail
   - Expose raw database errors to users
   
   **Rationale**: Ensures data consistency and security across all operations.
   
   **Verification**: All data paths must have validation tests; audit log must capture all mutations.
   ```

   #### Behavior Boundaries Section
   
   Add explicit negative prompting section:
   ```markdown
   ## Behavior Boundaries (Negative Prompting)
   
   These behaviors are EXPLICITLY FORBIDDEN regardless of circumstances:
   
   | Boundary | Forbidden Behavior | Why | Enforcement |
   |----------|-------------------|-----|-------------|
   | [ID] | [What must never happen] | [Reason] | [How enforced] |
   ```

   #### Invariants Section
   
   Conditions that must ALWAYS be true:
   ```markdown
   ## System Invariants
   
   - [INV-001]: [Condition that must always hold]
   - [INV-002]: [Another invariant]
   ```

4. **Consistency Propagation Checklist**:
   
   Validate alignment with dependent artifacts:
   
   - Read `.teammate/templates/plan-template.md` - ensure Principles Check aligns
   - Read `.teammate/templates/spec-template.md` - verify scope/requirements alignment
   - Read `.teammate/templates/actions-template.md` - ensure task types reflect principles
   - Read `.teammate/templates/feature-template.feature` - verify @principles scenarios align
   - Check any existing `features/*/scenarios/*.feature` for principles boundary scenarios

5. **Produce Sync Impact Report**:
   
   Prepend as an HTML comment at top of the principles file:
   ```markdown
   <!--
   Sync Impact Report
   Version change: [old] → [new]
   Modified principles: [list]
   Added sections: [list]
   Removed sections: [list]
   Templates requiring updates: [list with status]
   Follow-up TODOs: [if any]
   -->
   ```

6. **Validation Before Final Output**:
   
   - [ ] No remaining unexplained bracket tokens
   - [ ] Version line matches report
   - [ ] Dates in ISO format YYYY-MM-DD
   - [ ] Principles are declarative and testable
   - [ ] MUST/MUST NOT statements are clear and enforceable
   - [ ] Each principle has verification criteria
   - [ ] Behavior Boundaries section is complete
   - [ ] At least one invariant is defined

7. **Write the Completed Principles**:
   
   Write back to `.teammate/memory/principles.md` (overwrite).

8. **Update Active Context**:
   
   Update `.teammate/memory/active-context.md`:
   - Mark `principles` as complete
   - Record principles version and last amended date
   - Set next action as `teammate.align`

9. **Output Final Summary**:
   
   - New version and bump rationale
   - Principles defined (with MUST/MUST NOT counts)
   - Behavior boundaries defined
   - Invariants defined
   - Files flagged for manual follow-up
   - Suggested commit message

### Formatting Requirements

- Use Markdown headings exactly as in the template (do not demote/promote levels)
- Wrap long rationale lines for readability (<100 chars)
- Keep a single blank line between sections
- Avoid trailing whitespace
- Use tables for behavior boundaries

### Behavioral Integration

The principles integrate with the Teammate lifecycle:

1. **Align** (`teammate.align`): Principles inform what behaviors are acceptable
2. **Plan** (`teammate.plan`): Generate @principles scenarios from MUST NOT statements
3. **Execute** (`teammate.execute`): Principles boundary tests must pass before implementation
4. **Checklist** (`teammate.checklist`): Living docs show principles compliance status

### Example Principles Structure

```markdown
# [PROJECT_NAME] Principles

## Core Principles

### I. [Principle Name]

**MUST**:
- [Required behavior 1]
- [Required behavior 2]

**MUST NOT** (Negative Prompting):
- [Forbidden behavior 1]
- [Forbidden behavior 2]

**Rationale**: [Why this matters]

**Verification**: [How to check compliance]

## Behavior Boundaries (Negative Prompting)

| ID | Forbidden Behavior | Reason | Enforcement |
|----|-------------------|--------|-------------|
| BB-001 | [Behavior] | [Why forbidden] | [Test/Gate] |

## System Invariants

- **INV-001**: [Condition]
- **INV-002**: [Condition]

## Governance

- Principles supersede all other practices
- Amendments require documentation, approval, and migration plan
- All PRs/reviews must verify compliance

**Version**: [X.Y.Z] | **Ratified**: [DATE] | **Last Amended**: [DATE]
```

If critical info is missing, insert `TODO(<FIELD_NAME>): explanation` and include in the Sync Impact Report.
