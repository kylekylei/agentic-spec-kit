---
description: Execute the implementation planning workflow using Screenplay Pattern to define Actors, Abilities, and Tasks from .feature files.
handoffs: 
  - label: Create Actions
    agent: teammate.actions
    prompt: Break the plan into atomic verifiable actions
    send: true
  - label: Run Checklist
    agent: teammate.checklist
    prompt: Generate Living Documentation and verify feature readiness
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Create a technical implementation plan enhanced with **Screenplay Pattern** to ensure clean separation between WHO (Actors), WHAT (Tasks), and HOW (Abilities).

### Mode Detection

Parse `$ARGUMENTS` for the keyword **`update`**:

- If `$ARGUMENTS` contains "update" → **Update Mode**
- Otherwise → **Create Mode** (default)

**Update Mode** changes the execution behavior — see details below.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Update Mode

When running with `update`, the command preserves existing work and focuses on what changed.

#### Update Flow

1. **Pre-Update Snapshot**:
   - Read existing `FEATURE_DIR/tasks.md`
   - If file exists and is non-empty:
     1. Copy to `.teammate/snapshots/tasks-[feature]-YYYY-MM-DD.md`
     2. Ask user: **"What changed and why?"** (one line)
     3. Prepend reason as comment header in the snapshot
   - Also snapshot `screenplay.md` if it exists

2. **Collect Change Scope**:
   - Ask user what triggered the update (pick one or more):
     - [ ] Design changed (new/modified Figma, UI requirements)
     - [ ] Technical approach doesn't work (need different architecture/library)
     - [ ] New scenarios added (from `/teammate.plan` re-run)
     - [ ] Review/Execute found gaps (missing tasks, wrong estimates)
     - [ ] Scope change (features added/removed)
   - Load the user's description from `$ARGUMENTS` (after "update" keyword)

3. **Diff-Aware Processing**:
   - Load existing `tasks.md` and `screenplay.md` as baseline
   - Re-read current `.feature` files to detect new/changed/removed scenarios
   - Compare against baseline:
     - **New scenarios** → generate new tasks for them
     - **Removed scenarios** → mark affected tasks as obsolete
     - **Changed scenarios** → flag tasks that may need revision
     - **Unchanged scenarios** → **preserve existing tasks as-is**

4. **Output with Change Markers**:
   - Write updated `tasks.md` with change markers:
     ```
     <!-- [UNCHANGED] --> Tasks that were not affected
     <!-- [NEW] -->       Tasks added for new scenarios
     <!-- [REVISED] -->   Tasks modified due to changes
     <!-- [REMOVED] -->   Tasks no longer needed (commented out, not deleted)
     ```
   - Update `screenplay.md` only if actors/abilities changed

5. **Impact Report**:
   - Summary of what changed and why (from user input)
   - Count: [N] unchanged, [N] new, [N] revised, [N] removed
   - Downstream impact: "Run `/teammate.actions update` to reflect these changes"

#### Update Mode does NOT:
- Start from scratch — preserves all unchanged work
- Delete tasks silently — removed tasks are commented out with reason
- Skip the principles check — still validates foundation

---

### Execution Steps (Create Mode)

1. **Setup**: Run `.teammate/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for:
   - `FEATURE_SPEC`
   - `IMPL_TASKS`
   - `SPECS_DIR`
   - `BRANCH`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Load Context**:
   
   Required:
   - `FEATURE_SPEC` (spec.md)
   - `.teammate/memory/principles.md`
   - `FEATURE_DIR/scenarios/*.feature` (Gherkin files)
   
   Optional:
   - `FEATURE_DIR/example-mapping.md`
   - IMPL_TASKS template (already copied)
   - `docs/llms.txt` — Check for relevant external API/SDK references that this feature depends on. If found, read the corresponding `docs/[library]/llms.txt` for integration guidance.

3. **Phase 0: Screenplay Pattern Extraction**

   From the `.feature` files, extract the Screenplay model:

   #### Actors Discovery
   
   1. Identify all actors from scenarios:
      - "As a [Actor]" in Feature headers
      - "Given [Actor] is..." in steps
      - System actors (external systems, AI agents)
   
   2. For each actor, define:
      - Role description
      - Goals (from "So that" clauses)
      - Abilities needed

   #### Abilities Definition
   
   1. Group scenario steps by interaction type:
      - UI interactions → BrowseTheWeb ability
      - API calls → CallAnApi ability
      - Database access → QueryDatabase ability
      - Custom abilities as needed
   
   2. For each ability, define:
      - Purpose
      - Interface type (UI/API/CLI/Event)
      - Key operations
      - Production vs Test implementations

   #### Tasks Extraction
   
   1. From scenarios, identify high-level tasks:
      - Each scenario often maps to one or more tasks
      - Tasks are what actors want to accomplish
      - Tasks use abilities to interact with the system
   
   2. For each task, define:
      - Goal
      - Required abilities
      - Preconditions
      - Steps (sequence of interactions)
      - Postconditions
      - Mapped scenario(s)

4. **Generate Screenplay Document**:

   Create `FEATURE_DIR/screenplay.md` using `.teammate/templates/screenplay-template.md`:
   
   - Actors section with abilities
   - Abilities section with operations
   - Tasks section with steps and scenario mapping
   - Interaction map (visual)
   - Traceability matrix

5. **Phase 1: Technical Planning**

   Execute standard planning workflow:
   
   #### Technical Context
   
   Fill in from existing knowledge or research:
   - Language/Version
   - Primary Dependencies
   - Storage
   - Testing framework (BDD tool)
   - Target Platform
   - Performance Goals
   - Constraints

   #### Constitution Check
   
   Verify plan aligns with principles:
   - Map each principle to technical decisions
   - Note any conflicts or needed justifications
   
   *GATE: Must pass before proceeding*

   #### Project Structure
   
   Define code organization:
   - Source structure based on project type
   - Test structure for step definitions
   - Ability implementations location

6. **Phase 2: Research & Decisions**

   If NEEDS CLARIFICATION items exist:
   
   1. Generate research tasks for unknowns
   2. Consolidate findings in `research.md`:
      - Decision
      - Rationale
      - Alternatives considered

7. **Phase 3: Design Artifacts**

   Generate supporting documents:
   
   - `data-model.md` - Entities from feature requirements
   - `contracts/api/` - OpenAPI specs (if API involved)
   - `contracts/ui/` - Component specs (if UI involved)
   - `contracts/ai/` - Prompt contracts (if AI involved)
   - `quickstart.md` - Integration scenarios

   #### UI Design References (if UI involved)
   
   If this feature involves UI work:
   
   1. **Check `.teammate/memory/project-context.md`** for a project-level Figma link
   2. **Ask the user** for the specific Figma page link for this feature:
      - "Does this feature have a Figma design? If so, please provide the page link."
   3. **Record in `contracts/ui/`**:
      ```markdown
      ## Design Reference
      
      **Figma Page**: [URL provided by user]
      **Scope**: [Which scenarios/stories this design covers]
      ```
   4. If no Figma link provided, skip — not all features require UI design

8. **Update Agent Context**:

   Run `.teammate/scripts/bash/update-agent-context.sh cursor-agent`:
   - Update agent-specific context file
   - Add new technology from current plan
   - Preserve manual additions

9. **Update Active Context**:

   Update `.teammate/memory/active-context.md`:
   - Mark `tasks` as complete
   - Record key technical decisions
   - Set next action as `teammate.actions`

10. **Report Completion**:

    Output:
    - Branch name
    - IMPL_TASKS path (tasks.md)
    - Screenplay summary:
      - Actors: [count]
      - Abilities: [count]
      - Tasks: [count]
    - Generated artifacts list
    - Constitution check status
    - Suggested next command: `/teammate.actions`

## Screenplay Pattern Benefits

### Why Screenplay?

1. **Actor-Centric**: Tests describe what actors do, not how the system works
2. **Reusable**: Abilities and tasks can be shared across scenarios
3. **Maintainable**: Changes to interactions are localized to abilities
4. **Readable**: Tasks read like natural descriptions of user goals

### Screenplay Structure

```
Actor (who?) → Task (what?) → Ability (how?) → System
```

Example:
```
AuthenticatedUser → LoginWithCredentials → BrowseTheWeb → Login Page
```

### Mapping to Step Definitions

```gherkin
Given the user is on the login page
When the user enters valid credentials
Then the user sees the dashboard
```

Maps to:
```
Actor: User
Task: LoginWithValidCredentials
  - Uses: BrowseTheWeb ability
  - Steps:
    1. Navigate to login page
    2. Enter username
    3. Enter password
    4. Click submit
    5. Wait for dashboard
```

## Key Rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
- Screenplay model must be complete before actions
- All tasks must trace to scenarios
- All abilities must have defined operations
- **In update mode**: never discard work silently — mark, explain, and let the user decide
