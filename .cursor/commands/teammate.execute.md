---
description: Execute the Red-Green Loop implementation - write step definitions first (RED), then implement until GREEN, following the Actions.
handoffs:
  - label: Review Coverage
    agent: teammate.review
    prompt: Run a behavioral coverage analysis
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Execute implementation using the **Red-Green Loop** discipline, ensuring every line of code is driven by failing tests (step definitions).

### Argument Parsing

Parse `$ARGUMENTS` for special keywords:

| Keyword | Behavior |
|---------|----------|
| `next` | 自動找到 `actions.md` 中下一個未完成的 action（`- [ ]`），直接執行它 |
| `S0XX` | 執行指定 Action ID（如 `S006`） |
| `S0XX-S0YY` | 執行指定範圍的 actions（如 `S006-S010`） |
| _(empty)_ | 從頭開始，或從上次中斷處繼續 |
| _(other text)_ | 視為特定任務描述，尋找最匹配的 action |

#### `next` 模式流程

1. 讀取 `FEATURE_DIR/actions.md`
2. 掃描所有 action 行，找到第一個 `- [ ]`（未完成）的 action
3. 跳過所有 `- [x]`（已完成）的 action
4. 顯示：「**執行 S0XX**: [action 描述]」
5. 直接進入該 action 的 Red-Green Loop
6. 完成後標記為 `- [x]`，並報告下一個待執行的 action

### Red-Green Loop

```
RED → GREEN → REFACTOR → REPEAT
```

1. **RED**: Write step definitions that FAIL (scenario not implemented)
2. **GREEN**: Write minimum code to make step definitions PASS
3. **REFACTOR**: Clean up code while keeping tests GREEN
4. **REPEAT**: Move to next action

### Execution Steps

1. **Setup**: Run `.teammate/scripts/bash/check-prerequisites.sh --json --require-actions --include-actions` from repo root and parse:
   - `FEATURE_DIR`
   - `AVAILABLE_DOCS`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Check Checklists Status** (if `FEATURE_DIR/checklists/` exists):

   Scan all checklist files:
   - Count total, completed, incomplete items
   - Create status table
   
   ```
   | Checklist | Total | Completed | Incomplete | Status |
   |-----------|-------|-----------|------------|--------|
   | ux.md     | 12    | 12        | 0          | PASS |
   | test.md   | 8     | 5         | 3          | FAIL |
   ```
   
   - **If any incomplete**: STOP and ask user to confirm proceeding
   - **If all complete**: Auto-proceed

3. **Load Implementation Context**:

   Required:
   - `actions.md` - Actions with [Verifies: @tag] markers
   - `tasks.md` - Tech stack and structure
   - `scenarios/*.feature` - Gherkin scenarios
   
   Optional:
   - `screenplay.md` - Task definitions
   - `data-model.md` - Entities
   - `contracts/` - API specs
   - `docs/llms.txt` — Read the root index to discover available external references. For any third-party API/SDK used by this feature, load the corresponding `docs/[library]/llms.txt` for implementation guidance (e.g., correct method signatures, authentication patterns, error handling).

4. **Project Setup Verification**:

   Create/verify ignore files based on detected technology:
   - `.gitignore` (if git repo)
   - `.dockerignore` (if Docker detected)
   - `.eslintignore` (if ESLint detected)
   - etc.

5. **Parse Tasks Structure**:

   Extract from actions.md:
   - Phases and their actions
   - `[Verifies: @tag]` markers for each action
   - Parallel markers `[P]`
   - Dependencies

6. **Execute Red-Green Loop**:

   For each phase, for each action:

   #### If Action is Step Definition:
   
   1. **Read the scenario** from `.feature` file (use the @tag from `[Verifies: @tag]`)
   2. **Write step definitions** that map to the Gherkin steps
   3. **Run the scenario** - expect **RED** (steps not implemented yet)
   4. **If RED**: Mark action in progress, proceed to implementation actions
   5. **If GREEN**: Warning - scenario already passes, verify correctness

   #### If Action is Implementation:
   
   1. **Identify which step definitions** this action supports (from `[Verifies: @tag]`)
   2. **Write minimum implementation** to make those steps pass
   3. **Run the scenario** - aim for **GREEN**
   4. **If GREEN**: Mark action complete, proceed to next
   5. **If RED**: Debug, fix, re-run until GREEN

   #### Refactor Phase:
   
   After each story's actions are GREEN:
   1. Review code for duplication
   2. Apply appropriate patterns
   3. Ensure tests still GREEN
   4. Commit with story reference

7. **Phase-by-Phase Execution**:

   - **Setup Phase**: Initialize project, dependencies, configuration
   - **Foundational Phase**: Core infrastructure (blocks all stories)
   - **Story Phases**: One phase per user story in priority order
     - Step definitions first (RED)
     - Implementation (aim for GREEN)
     - Integration if needed
   - **Polish Phase**: Cross-cutting concerns, documentation

8. **Parallel Execution Rules**:

   Actions marked `[P]` can run in parallel if:
   - They modify different files
   - They have no dependencies on incomplete actions
   - They verify independent scenarios

9. **Progress Tracking**:

   After each completed action:
   - Mark as `[X]` in actions.md
   - Report progress
   - Update `.teammate/memory/progress.md`

   For failed actions:
   - Report error with context
   - Suggest debugging steps
   - Do not proceed to dependent actions

10. **Completion Validation**:

    At phase completion:
    - All actions in phase marked complete
    - All scenarios for that phase are GREEN
    - No failing tests
    - Code follows project conventions

11. **Update Active Context**:

    Update `.teammate/memory/active-context.md`:
    - Current phase and action
    - Scenarios passing/failing
    - Blockers if any
    - Set next action as `teammate.review`

12. **Report Completion**:

    At feature completion:
    - All scenarios GREEN
    - All actions complete
    - Living documentation updated
    - Suggested next command: `/teammate.review`

## Red-Green Loop Discipline

### Why RED First?

Writing step definitions before implementation ensures:
1. You understand the behavior before coding
2. You have a failing test to guide implementation
3. You know exactly when you're done (GREEN)
4. You avoid over-engineering

### Step Definition Patterns

```python
# Python/Behave example
from behave import given, when, then

@given('the user is on the login page')
def step_user_on_login_page(context):
    context.page.navigate_to('/login')

@when('the user enters valid credentials')
def step_enter_valid_credentials(context):
    context.page.fill('username', 'testuser')
    context.page.fill('password', 'password123')
    context.page.click('submit')

@then('the user sees the dashboard')
def step_see_dashboard(context):
    assert context.page.url == '/dashboard'
```

### Minimum Implementation

Write only enough code to make the current step definition pass:
- Don't add features not yet tested
- Don't optimize prematurely
- Don't handle edge cases not in scenarios

### Refactor Safely

After GREEN:
- Extract common code
- Improve naming
- Apply patterns
- Run tests after each change
- Keep GREEN throughout

## Implementation Execution Rules

- **Setup first**: Project structure, dependencies
- **Foundation before stories**: Shared infrastructure
- **Stories in priority order**: P1 → P2 → P3
- **Step definitions before code**: Always RED first
- **Commit after each GREEN**: Small, traceable commits

## Error Handling

If an action fails:
1. Report the error with full context
2. Show the failing scenario and step
3. Suggest potential fixes
4. Wait for user direction
5. Do not proceed to dependent actions

For parallel actions:
- Continue with successful actions
- Report failed actions
- User can choose to fix or skip
