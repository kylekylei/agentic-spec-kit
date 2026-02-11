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
   - [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
   ```

   Components:
   - `[ActionID]`: Sequential (S001, S002, S003...)
   - `[Type]`: Action type - **REQUIRED** - one of:
     - `[LOGIC]` — model/store/service/util/config，有可自動化測試的邏輯
     - `[UI]` — 純 UI 組件，無獨立邏輯可測試
     - `[LOGIC+UI]` — 含邏輯的 UI 組件（如有 store 互動的面板）
   - `[P]`: Parallel marker (optional - different files, no dependencies)
   - `[Story]`: User story marker (US1, US2, US3...)
   - `[Verifies: @tag]`: Links to scenario tag(s) - **REQUIRED**
   - Description: Clear action with exact file path

   Examples:
   - `- [ ] S012 [LOGIC] [P] [US1] [Verifies: @us1-login-success] Create User model in src/models/user.py`
   - `- [ ] S015 [LOGIC] [US1] [Verifies: @us1-login-success, @us1-login-failure] Implement AuthService in src/services/auth.py`
   - `- [ ] S020 [UI] [US2] [Verifies: @us2-dashboard] Create Dashboard.svelte in src/components/`
   - `- [ ] S025 [LOGIC+UI] [US3] [Verifies: @us3-notification] Create TaskNotifier.svelte with store integration`

6. **Integration Actions**:

   For every `[INTEGRATE]` file listed in `tasks.md` project structure, generate a corresponding mount/import action:

   ```markdown
   - [ ] S0XX [US?] [Verifies: @rule-X.X] 在 `[consumer file]` 中掛載 `[NEW component]`（import + render）
   ```

   Rules:
   - Place integration actions **immediately after** the component creation action (e.g., S031 creates TaskNotifier → S031a integrates into +layout.svelte)
   - Integration actions inherit the `[Verifies]` tags of the component they mount
   - If the integration requires conditional rendering (e.g., only when logged in), note it in the action description

   Example:
   ```markdown
   - [ ] S031 [US2] [Verifies: @rule-2.1] 建立 TaskNotifier.svelte
   - [ ] S031a [US2] [Verifies: @rule-2.1] 在 +layout.svelte 掛載 TaskNotifier（已登入時渲染）
   ```

7. **Phase Structure**:

   Organize actions into phases:
   
   - **Phase 1: Setup** - `[Verifies: @setup]` - Project initialization
   - **Phase 2: Foundational** - `[Verifies: @foundation]` - Core infrastructure
   - **Phase 3+: User Stories** - `[Verifies: @usX-*]` - Story-specific actions
   - **Phase N: Polish** - `[Verifies: @polish, @cross-cutting]` - Final touches

8. **Generate Traceability Matrix**:

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

9. **Coverage Validation**:

   Verify every scenario is covered:
   
   - [ ] Every @P1 scenario has at least one action
   - [ ] Every @happy-path scenario has implementation actions
   - [ ] Every @principles scenario has verification actions
   - [ ] No orphan actions (actions without scenario links)

10. **Write Tasks File**:

   Write to `FEATURE_DIR/actions.md` using `.teammate/templates/actions-template.md`:
   
   - Correct feature name
   - All phases with proper structure
   - All actions with [Verifies: @tag] markers
   - Traceability matrix
   - Dependencies and execution order
   - Red-Green Loop instructions

11. **Update Active Context**:

    Update `.teammate/memory/active-context.md`:
    - Mark `actions` as complete
    - Record action count and coverage
    - Set next action as `teammate.execute`

12. **Report Completion**:

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
4. REFLECT if new insights discovered
5. Mark action complete

### RED/GREEN Forced Split（強制拆分規則）

`[LOGIC]` 和 `[LOGIC+UI]` 類型的 action，若涉及 util / store / service / model 等可測試邏輯，MUST 拆為兩個連續 actions：

```markdown
- [ ] S010 [LOGIC] [US1] [Verifies: @us1-auth] RED: 建立 AuthService 測試 in tests/services/auth.test.ts
- [ ] S011 [LOGIC] [US1] [Verifies: @us1-auth] GREEN: 實作 AuthService in src/services/auth.ts
```

規則：
- RED action 只寫測試，不寫實作
- GREEN action 只寫實作，讓測試通過
- RED action 的 ID 必須在 GREEN action 之前（確保先 RED 再 GREEN）
- `[UI]` 類型不強制拆分（純 UI 無可自動化的 RED 測試）
- `[LOGIC+UI]` 拆分邏輯部分的 RED/GREEN，UI 部分單獨一個 action

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
