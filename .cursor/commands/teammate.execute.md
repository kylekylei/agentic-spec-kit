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

1. 讀取 `FEATURE_DIR/plan.md` 的 Part 2（Actions）
2. 掃描所有 action 行，找到第一個 `- [ ]`（未完成）的 action
3. 跳過所有 `- [x]`（已完成）的 action
4. 顯示：「**執行 S0XX**: [action 描述]」
5. 直接進入該 action 的 Red-Green Loop
6. 完成後標記為 `- [x]`，並報告下一個待執行的 action

### Red-Green Loop

```
RED → GREEN → REFACTOR → REFLECT → REPEAT
```

1. **RED**: Write step definitions that FAIL (scenario not implemented)
2. **GREEN**: Write minimum code to make step definitions PASS
3. **REFACTOR**: Clean up code while keeping tests GREEN
4. **REFLECT**: 快速自檢（≤ 30 秒），有新發現才寫入 `insights.md`
5. **REPEAT**: Move to next action

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

   **Required**（必載）:
   - `plan.md` - Part 1 (Architecture: tech stack, project structure) + Part 2 (Actions: phased execution checklist)
   - `scenarios/*.feature` - Gherkin scenarios

   **Recommended**（條件必載 — 存在即載入，不得跳過）:
   - `FEATURE_DIR/insights.md` — 當前 feature 的動態備忘錄（如存在）
   - 最近 2 個已完成 feature 的 `insights.md` — 跨 feature 知識傳遞
   - `docs/llms.txt` — Read the root index, load corresponding `docs/[library]/llms.txt` for implementation guidance
   - `contracts/` — API / UI / AI contracts（如目錄存在，UI specs 在 `contracts/ui/ui-spec.md`）

   **Optional**（輔助參考）:
   - `data-model.md` - Entities
   - `research.md` - Decisions

   > **反簡短偏差**：Recommended 層級的資源不得以「節省 context」為由跳過。只取最近 2 個 insights 是為了避免 context window 過載；足夠重要的 insight 會「畢業」到 project-context。

4. **Project Setup Verification**:

   Create/verify ignore files based on detected technology:
   - `.gitignore` (if git repo)
   - `.dockerignore` (if Docker detected)
   - `.eslintignore` (if ESLint detected)
   - etc.

5. **Parse Plan Structure**:

   Extract from `plan.md` Part 2 (Actions):
   - Phases and their actions
   - `[Verifies: @tag]` markers for each action
   - Parallel markers `[P]`
   - Action types `[LOGIC]`/`[UI]`/`[LOGIC+UI]`
   - Dependencies

6. **Risk-Based HITL Gates**（風險暫停）:

   在執行每個 action 前，檢查以下風險條件。觸發時自動暫停並詢問用戶：

   | 風險觸發條件 | 暫停行為 |
   |-------------|---------|
   | Action 涉及 `@principles` tag 或修改 `principles.md` 邊界程式碼 | 「此 action 修改 Principles 邊界程式碼，確認繼續？」 |
   | Action 需刪除或重命名檔案 | 「此 action 需要刪除/重命名 [file]，確認？」 |
   | Action 修改共用基礎設施（config、shared utils、store、layout） | 「此 action 影響共用模組 [module]，可能影響其他 features，確認？」 |
   | REFLECT 發現使用了 codebase 中不存在的新 pattern | 「此 action 引入了新 pattern [X]，codebase 現有慣例為 [Y]，確認使用新 pattern？」 |

   規則：
   - 只在上述條件下暫停，不影響正常 action 的執行效率
   - 用戶可回覆「繼續」或「調整」
   - 暫停事件記錄到 `active-context.md`

7. **Execute Red-Green Loop**:

   For each phase, for each action:

   #### Action Type Detection

   根據 action 的類型標記（`[LOGIC]`/`[UI]`/`[LOGIC+UI]`）決定執行策略：

   | 類型 | RED 階段 | GREEN 階段 |
   |------|---------|-----------|
   | `[LOGIC]` | 寫 unit test（期望 RED） | 寫最小實作讓 test GREEN |
   | `[UI]` | **智能分流**（見下方） | 實作 UI 組件 |
   | `[LOGIC+UI]` | 寫 unit test + 智能分流 | 實作邏輯 + UI |

   > 若 action 無類型標記，依 action 描述推斷：涉及 model/store/service/util → `[LOGIC]`；涉及 .svelte/.tsx/.vue 組件 → `[UI]`；兩者皆有 → `[LOGIC+UI]`。

   #### UI 智能分流

   對 `[UI]` 和 `[LOGIC+UI]` 類型的 action：
   - **有 Figma link 或兄弟組件可參考** → AI 自行推斷視覺設計，直接實作，不暫停
   - **有不確定的細節**（無先例的佈局、衝突的設計語言） → 暫停並**主動列出選項**（非開放式提問）讓使用者選擇
   - **完全無參考** → 完整暫停，展示視覺規格確認後再實作

   推斷依據：`contracts/ui/`、`principles.md` 設計系統、`insights.md` 記錄的兄弟組件慣例。

   #### If Action is Step Definition:
   
   1. **Read the scenario** from `.feature` file (use the @tag from `[Verifies: @tag]`)
   2. **Write step definitions** that map to the Gherkin steps
   3. **Run the scenario** - expect **RED** (steps not implemented yet)
   4. **If RED**: Mark action in progress, proceed to implementation actions
   5. **If GREEN**: Warning - scenario already passes, verify correctness

   #### If Action is Implementation:

   1. **Test Pre-Check**（`[LOGIC]` 和 `[LOGIC+UI]` 類型）：
      - 檢查此 action 對應的 test 檔案是否已存在
      - 若不存在且 plan.md 中有對應的 RED:test action 未完成 → 警告：「對應的測試 action [S0XX] 尚未完成，建議先執行測試 action」
      - 用戶可選擇繼續或先執行測試
   2. **Identify which step definitions** this action supports (from `[Verifies: @tag]`)
   3. **Write minimum implementation** to make those steps pass
   4. **Run the scenario** - aim for **GREEN**
   5. **If GREEN**: Mark action complete, proceed to next
   6. **If RED**: Debug, fix, re-run until GREEN

   #### Refactor Phase:
   
   After each story's actions are GREEN:
   1. Review code for duplication
   2. Apply appropriate patterns
   3. Ensure tests still GREEN
   4. Commit with story reference

   #### REFLECT Phase:

   每個 action GREEN 後，進行 ≤ 30 秒的快速自檢：

   1. 發現了 codebase 慣例或 pattern？
   2. 踩到了陷阱或需要注意的事項？
   3. 做了需要記錄的技術決策？
   4. 做了涉及替代方案取捨的選擇？（→ Decision Log）
   5. 先前 insight 需修正？

   規則：
   - **有新發現才寫入** `FEATURE_DIR/insights.md`，無則跳過（避免噪音）
   - 首次寫入時，從 `.teammate/templates/insights-template.md` 複製模板
   - 寫入時標記 Action ID（如 `[S003]`）保留可追溯性
   - 格式範例：`- [S003] Svelte reactive 一律使用 $derived，不用 $: IIFE`

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
   - Mark as `[X]` in plan.md (Part 2: Actions)
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

11. **Phase Completion Sync**（階段完成同步）:

    當一個 Phase 的所有 actions 都完成時，MUST 執行以下同步：

    1. **更新 `progress.md`**：
       - Feature Registry 中該 feature 的 Status 更新為當前 Phase
       - Deliverables 反映已完成的產出
       - Metrics 更新（通過的 scenarios 數、action 完成率）

    2. **更新 `active-context.md`**：
       - Current Phase 更新為下一個 Phase
       - Next Actions 列出下一 Phase 的第一個 action
       - 記錄已完成 Phase 的摘要

    > 此步驟確保 memory 與實際進度同步，避免 Feature Registry 仍顯示 Pending 的脫節問題。

12. **Update Active Context**（Memory Delta Protocol）:

    Update `.teammate/memory/active-context.md` using delta mode:
    - **覆寫 `## Current State`**：Phase: Deliver, Last Command: execute [action ID], Next Action: [next action or /teammate.review]
    - **追加 `## Session Log`**：`| [timestamp] | execute [ID] | [GREEN/RED], [action description] | [insights discovered if any] |`
    - **更新 `## Blockers`**：如有 failing scenarios 或 Risk Gate 暫停，記錄為 blocker；已解決的標記 `[RESOLVED]`

13. **Report Completion**:

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

### Why REFLECT?

REFLECT 確保執行過程中的隱性知識被結構化保留：
1. Codebase 慣例不再靠 AI「下次記得」，而是寫在 `insights.md`
2. 跨 action 知識傳遞：後續 action 可參考先前 action 的 insights
3. 跨 feature 知識傳遞：Smart Context Loading 會載入最近 features 的 insights
4. 決策軌跡可回溯：事後可追蹤 AI 選擇了什麼、為什麼

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

### REFLECT Quickly

After REFACTOR:
- ≤ 30 秒的快速自檢，不是長篇報告
- 只在有實質發現時才寫入 `insights.md`
- 記錄格式：`- [S0XX] 發現內容`
- 五個固定問題：慣例？陷阱？決策？取捨？修正？

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
