---
description: Generate atomic, verifiable implementation actions linked to Gherkin scenarios for full traceability.
handoffs: 
  - label: Review Coverage
    agent: teammate.review
    prompt: Run a behavioral coverage analysis
    send: true
  - label: Execute Actions
    agent: teammate.execute
    prompt: Start the Red-Green Loop implementation
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Transform the plan and Screenplay model into **atomic implementation actions** where each action links to specific Gherkin scenarios for full traceability.

### Mode Detection

Parse `$ARGUMENTS` for the keyword **`update`**:

- If `$ARGUMENTS` contains "update" → **Update Mode**
- Otherwise → **Create Mode** (default)

#### Update Mode

When running with `update` (typically after `/teammate.tasks update`):

1. **Snapshot** existing `actions.md` to `.teammate/snapshots/actions-[feature]-YYYY-MM-DD.md`
2. **Load existing actions** as baseline
3. **Compare against current `tasks.md`** to detect new/changed/removed tasks
4. **Preserve completed actions** (marked `[X]`) — never discard finished work
5. **Generate new actions** only for new or revised tasks
6. **Mark changes**:
   ```
   <!-- [UNCHANGED] --> Existing actions, not affected
   <!-- [NEW] -->       Actions for newly added tasks
   <!-- [REVISED] -->   Actions updated due to task changes
   <!-- [REMOVED] -->   Actions no longer needed (commented out)
   ```
7. **Report**: [N] unchanged, [N] new, [N] revised, [N] removed

### Action Concept

Each action in the chain:
- Is atomic and independently completable
- Links to one or more Gherkin scenarios via `[Verifies: @tag]`
- Forms a traceable chain from behavior to implementation
- Follows Red-Green Loop (step definitions first, then implementation)

### Execution Steps

1. **Setup**: Run `.teammate/scripts/bash/check-prerequisites.sh --json` from repo root and parse:
   - `FEATURE_DIR`
   - `AVAILABLE_DOCS`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Load Design Documents**:

   Required:
   - `tasks.md` - Tech stack, structure
   - `spec.md` - User stories with priorities
   - `scenarios/*.feature` - Gherkin scenarios (THE SOURCE OF TRUTH)
   
   Optional:
   - `screenplay.md` - Actors, Abilities, Tasks
   - `data-model.md` - Entities
   - `contracts/` - API endpoints
   - `research.md` - Decisions

3. **Extract Scenario Tags**:

   Parse all `.feature` files to build tag inventory:
   
   | Tag | Scenario | Priority | Type |
   |-----|----------|----------|------|
   | @us1-login-success | User successfully logs in | @P1 | @happy-path |
   | @us1-login-failure | Login fails with invalid password | @P1 | @negative |

4. **Generate Actions by User Story**:

   For each user story (in priority order):

   #### Step Definitions Phase
   
   Generate actions for step definitions FIRST:
   ```markdown
   - [ ] S0XX [P] [US1] [Verifies: @us1-happy-path] Step definitions for [scenario] in tests/step-definitions/[file]
   - [ ] S0XX [P] [US1] [Verifies: @us1-negative] Step definitions for [scenario] in tests/step-definitions/[file]
   ```

   #### Implementation Phase
   
   Generate implementation actions linked to scenarios:
   ```markdown
   - [ ] S0XX [P] [US1] [Verifies: @us1-happy-path] Create [Entity] model in src/models/[entity].py
   - [ ] S0XX [US1] [Verifies: @us1-happy-path, @us1-alternative] Implement [Service] in src/services/[service].py
   ```

5. **Action Format**:

   Every action MUST follow this format:
   ```
   - [ ] [ActionID] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
   ```

   Components:
   - `[ActionID]`: Sequential (S001, S002, S003...)
   - `[P]`: Parallel marker (optional - different files, no dependencies)
   - `[Story]`: User story marker (US1, US2, US3...)
   - `[Verifies: @tag]`: Links to scenario tag(s) - **REQUIRED**
   - Description: Clear action with exact file path

   Examples:
   - `- [ ] S012 [P] [US1] [Verifies: @us1-login-success] Create User model in src/models/user.py`
   - `- [ ] S015 [US1] [Verifies: @us1-login-success, @us1-login-failure] Implement AuthService in src/services/auth.py`
   - `- [ ] S012 [US1] Create User model` (missing Verifies tag)

6. **Phase Structure**:

   Organize actions into phases:
   
   - **Phase 1: Setup** - `[Verifies: @setup]` - Project initialization
   - **Phase 2: Foundational** - `[Verifies: @foundation]` - Core infrastructure
   - **Phase 3+: User Stories** - `[Verifies: @usX-*]` - Story-specific actions
   - **Phase N: Polish** - `[Verifies: @polish, @cross-cutting]` - Final touches

7. **Generate Traceability Matrix**:

   Build and include the traceability matrix:
   
   ```markdown
   ## Traceability Matrix
   
   | Scenario Tag | Actions | Status |
   |--------------|---------|--------|
   | @us1-login-success | S010, S012-S015 | Pending |
   | @us1-login-failure | S011, S016 | Pending |
   | @principles-data-integrity | S008 | Pending |
   
   **Coverage**: [X]/[Y] scenarios have linked actions ([Z]%)
   ```

8. **Coverage Validation**:

   Verify every scenario is covered:
   
   - [ ] Every @P1 scenario has at least one action
   - [ ] Every @happy-path scenario has implementation actions
   - [ ] Every @principles scenario has verification actions
   - [ ] No orphan actions (actions without scenario links)

9. **Write Tasks File**:

   Write to `FEATURE_DIR/actions.md` using `.teammate/templates/actions-template.md`:
   
   - Correct feature name
   - All phases with proper structure
   - All actions with [Verifies: @tag] markers
   - Traceability matrix
   - Dependencies and execution order
   - Red-Green Loop instructions

10. **Update Active Context**:

    Update `.teammate/memory/active-context.md`:
    - Mark `actions` as complete
    - Record action count and coverage
    - Set next action as `teammate.execute`

11. **Report Completion**:

    Output:
    - Path to actions.md
    - Summary:
      - Total actions: [N]
      - Actions per story: [breakdown]
      - Scenario coverage: [X]/[Y] ([Z]%)
    - Parallel opportunities identified
    - Suggested MVP scope
    - Next command: `/teammate.execute`

## Action Principles

### Atomic & Verifiable

Each action must be:
- Small enough to complete in one session
- Large enough to be meaningful
- Independently verifiable against its scenario(s)

### Traceable Chain

```
Scenario (@tag) → Action (S0XX) → Implementation → Verification
```

### Red-Green Loop Ready

Actions are ordered to support:
1. Write step definitions → expect RED
2. Implement minimum code → expect GREEN
3. Refactor if needed
4. Mark action complete

## Action Generation Rules

### From Scenarios

Each scenario generates:
1. Step definition action(s)
2. Implementation action(s) based on steps
3. Integration action if multiple components involved

### From Screenplay

If screenplay.md exists:
- Map Tasks to actions
- Map Abilities to implementation actions
- Ensure Actor setup in foundational phase

### Dependencies

- Models before services
- Services before endpoints
- Step definitions before implementation
- Foundation before user stories
