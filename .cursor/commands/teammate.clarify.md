---
description: Transform abstract requirements into concrete examples using Example Mapping (Story ??Rules ??Examples ??Questions).
handoffs: 
  - label: Create Work Plan
    agent: teammate.plan
    prompt: Generate Gherkin feature files from the examples
    send: true
  - label: Define Tasks
    agent: teammate.tasks
    prompt: Create a technical plan with Screenplay Pattern for the feature
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Transform abstract user stories into concrete, testable examples using the **Example Mapping** technique. This creates the foundation for Gherkin scenarios.

Note: This workflow should run AFTER `/teammate.align` has produced a spec.md. If the user explicitly states they are skipping align (e.g., existing requirements), you may proceed but must warn about potential gaps.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Execution Steps

1. **Setup**: Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root. Parse JSON for:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Load context**:
   - Read FEATURE_SPEC (spec.md)
   - Read `.teammate/memory/principles.md`
   - If exists, read any previous example-mapping.md

3. **For each User Story** (in priority order P1, P2, P3...):

   Execute the Example Mapping session:

   #### Step 1: Story Card (Yellow)
   
   - Extract the user story in As a / I want / So that format
   - Confirm the business value

   #### Step 2: Rules Discovery (Blue)
   
   - For each story, identify the **business rules** that govern it:
     - What conditions must be true?
     - What constraints exist?
     - What variations are allowed?
     - What is NOT allowed? (principles boundaries)
   
   - For each rule:
     - Write a clear, testable statement
     - Verify it's a RULE (not an example)
     - Check against principles for conflicts

   #### Step 3: Examples Generation (Green)
   
   - For each rule, generate **concrete examples**:
     - At least one **happy path** example
     - At least one **alternative** example (if applicable)
     - At least one **negative/error** example
     - Consider **boundary conditions**
   
   - Each example follows Given/When/Then:
     | Given (Context) | When (Action) | Then (Outcome) | Type |
     |-----------------|---------------|----------------|------|
     | [Specific state] | [Specific action] | [Specific result] | Happy/Alt/Neg |

   #### Step 4: Questions Collection (Red)
   
   - Capture any **questions** that arise:
     - Ambiguous requirements
     - Missing information
     - Edge cases not covered
     - Principles conflicts
   
   - For each question:
     - State the question clearly
     - Assess impact (High/Medium/Low)
     - Mark as Open or Resolved

4. **Principles Boundary Check**:
   
   For each rule and example, verify:
   - Does this violate any principles principle?
   - Are there behaviors that MUST NOT occur?
   - Add explicit principles boundary examples

5. **Generate Example Mapping Document**:

   Write to `FEATURE_DIR/example-mapping.md` using `.teammate/templates/example-mapping-template.md`:
   
   - Story header with priority
   - All rules with clear statements
   - Examples table for each rule (Given/When/Then)
   - Questions with impact assessment
   - Principles boundaries
   - Readiness checklist

6. **Interactive Refinement** (if questions exist):

   For each HIGH impact open question:
   
   a. Present the question with context
   b. Provide suggested answers with implications
   c. Wait for user response
   d. Update the example mapping with the answer
   e. Add any new rules or examples that emerge
   
   Maximum 5 questions per session.

7. **Readiness Assessment**:

   Check the Example Mapping readiness:
   
   | Metric | Current | Target | Status |
   |--------|---------|--------|--------|
   | Rules per story | [N] | 3+ | [Pass/Fail] |
   | Examples per rule | [Avg] | 2+ | [Pass/Fail] |
   | Open questions | [N] | 0 high-impact | [Pass/Fail] |
   | Principles boundaries | [N] | 1+ per story | [Pass/Fail] |

8. **Update Active Context**:

   Update `.teammate/memory/active-context.md`:
   - Mark `clarify` as complete
   - Note any deferred questions
   - Set next action as `teammate.plan`

9. **Report Completion**:

   Output:
   - Path to example-mapping.md
   - Summary: Stories processed, Rules identified, Examples generated
   - Open questions count (by impact level)
   - Readiness status for `/teammate.plan`
   - Suggested next command: `/teammate.plan`

## Example Mapping Best Practices

### Good Rules (Blue Cards)
- "Users must be authenticated to access protected resources"
- "Passwords must be at least 8 characters with mixed case"
- "Orders cannot be modified after shipping"

### Bad Rules (Too Vague)
- "The system should be secure" ??What specifically?
- "It must be fast" ??What threshold?
- "Users should have a good experience" ??What behaviors?

### Good Examples (Green Cards)
| Given | When | Then |
|-------|------|------|
| User has valid credentials | User submits login form | User is redirected to dashboard |
| User has invalid password | User submits login form | Error message "Invalid credentials" shown |
| User account is locked | User submits login form | Error message "Account locked" with unlock instructions |

### Principles Boundaries
For each story, explicitly add examples that show:
- What the system MUST NOT do
- How principles principles constrain behavior
- Negative examples that protect invariants

## Behavior Rules

- If no meaningful user stories found, instruct user to run `/teammate.align` first
- If spec file missing, ERROR and suggest `/teammate.align`
- Never exceed 5 questions per session
- Respect user early termination signals ("stop", "done", "proceed")
- Always produce example-mapping.md even if questions remain (mark as draft)
- Prioritize principles boundary examples for P1 stories
