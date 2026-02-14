---
description: 執行 Red-Green 迴圈實作 — 先寫步驟定義（RED），再實作至 GREEN，依 Actions 順序進行。
handoffs:
  - label: 行為覆蓋審查
    agent: teammate.review
    prompt: 執行行為覆蓋率分析
    send: true
---

## 使用者輸入

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量後再繼續。

## 大綱

目標：依 **Red-Green 迴圈**紀律執行實作，確保每行程式碼皆由失敗測試（步驟定義）驅動。

### 參數解析

解析 `$ARGUMENTS` 的特殊關鍵字：

| 關鍵字 | 行為 |
|---------|----------|
| `next` | 自動找到 `plan.md` Part 2 中下一個未完成的 action（`- [ ]`），直接執行它 |
| `S0XX` | 執行指定 Action ID（如 `S006`） |
| `S0XX-S0YY` | 執行指定範圍的 actions（如 `S006-S010`） |
| _(empty)_ | 從頭開始，或從上次中斷處繼續 |
| _(other text)_ | 視為特定任務描述，尋找最匹配的 action |

#### `next` 模式流程

1. 讀取 `TASK_DIR/plan.md` 的 Part 2（Actions）
2. 掃描所有 action 行，找到第一個 `- [ ]`（未完成）的 action
3. 跳過所有 `- [x]`（已完成）的 action
4. 顯示：「**執行 S0XX**: [action 描述]」
5. 直接進入該 action 的 Red-Green Loop
6. 完成後標記為 `- [x]`，並報告下一個待執行的 action

### Red-Green 迴圈

```
RED → GREEN → REFACTOR → REFLECT → REPEAT
```

1. **RED**：撰寫會失敗的步驟定義（情境尚未實作）
2. **GREEN**：撰寫最小程式碼使步驟定義通過
3. **REFACTOR**：清理程式碼，保持測試 GREEN
4. **REFLECT**：快速自檢（≤ 30 秒），有新發現才寫入 `insights.md`
5. **REPEAT**：移至下一個 action

### 執行步驟

1. **Setup**：從 repo 根目錄執行 `.teammate/scripts/bash/check-prerequisites.sh --json --require-plan --include-plan` 並解析：
   - `TASK_DIR`
   - `AVAILABLE_DOCS`
   - 參數含單引號（如 "I'm Groot"）時使用 escape 語法：例如 `'I'\''m Groot'`

2. **檢查清單狀態**（若 `TASK_DIR/checklists/` 存在）：

   掃描所有 checklist 檔案：
   - 統計總數、已完成、未完成項目
   - 建立狀態表
   
   ```
   | Checklist | Total | Completed | Incomplete | Status |
   |-----------|-------|-----------|------------|--------|
   | ux.md     | 12    | 12        | 0          | PASS |
   | test.md   | 8     | 5         | 3          | FAIL |
   ```
   
   - **若有未完成**：暫停並詢問使用者是否繼續
   - **若全部完成**：自動繼續

3. **載入實作脈絡**：

   **Staleness Check**：比對 `spec.md` 和 `plan.md` 的修改時間。若 spec.md 比 plan.md 新 → 警告：「spec.md 在 plan.md 之後被更新，plan 可能已過期。建議先執行 `/teammate.plan update`，或確認變更不影響 plan 後繼續。」用戶可選擇繼續或先更新。

   **必載**:
   - `plan.md` — Part 1（架構：技術棧、專案結構）+ Part 2（Actions：分階段執行清單）
   - `scenarios/*.feature` — Gherkin 情境

   **條件必載**（存在即載入，不得跳過）:
   - `TASK_DIR/insights.md` — 當前任務的動態備忘錄（如存在）
   - 最近 2 個已完成任務的 `insights.md` — 跨任務知識傳遞
   - `.teammate/memory/agent-spec.md` — AI Agent 行為規範（如存在）
   - `docs/llms.txt` — 讀取根索引，載入對應 `docs/[library]/llms.txt` 作為實作指引
   - `contracts/` — API / UI / AI 合約（如目錄存在，UI 規格在 `contracts/ui/ui-spec.md`）

   **Compliance Skills**（動態偵測，偵測到才載入）:
   - 前端偵測到 → 載入 `.cursor/skills/a11y-compliance/SKILL.md`（`[UI]` 和 `[LOGIC+UI]` action 實作時參考 POUR 原則與代碼範例）
   - AI/LLM 偵測到 → 載入 `.cursor/skills/ai-compliance/SKILL.md`（AI 相關 action 實作時參考合規規則與代碼範例）

   **輔助參考**:
   - `data-model.md` — 實體
   - `research.md` — 決策紀錄

   > **反簡短偏差**：Recommended 層級的資源不得以「節省 context」為由跳過。只取最近 2 個 insights 是為了避免 context window 過載；足夠重要的 insight 會「畢業」到 context.md。

4. **專案設定驗證**：

   依偵測到的技術建立/驗證 ignore 檔案：
   - `.gitignore`（若為 git repo）
   - `.dockerignore`（若偵測到 Docker）
   - `.eslintignore`（若偵測到 ESLint）
   - 等

5. **解析計畫結構**：

   從 `plan.md` Part 2（Actions）擷取：
   - 各 Phase 及其 actions
   - 每個 action 的 `[Verifies: @tag]` 標記
   - 平行標記 `[P]`
   - Action 類型 `[LOGIC]`/`[UI]`/`[LOGIC+UI]`
   - 相依關係

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
   - 暫停事件記錄到 `progress.md`

7. **執行 Red-Green 迴圈**：

   對每個 phase、每個 action：

   #### Action 類型偵測

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

   #### 若 Action 為步驟定義：
   
   1. 從 `.feature` 檔案**讀取情境**（使用 `[Verifies: @tag]` 的 @tag）
   2. **撰寫步驟定義**對應 Gherkin 步驟
   3. **執行情境** — 預期 **RED**（步驟尚未實作）
   4. **若 RED**：標記 action 進行中，繼續實作 actions
   5. **若 GREEN**：警告 — 情境已通過，需驗證正確性

   #### 若 Action 為實作：

   1. **Test Pre-Check**（`[LOGIC]` 與 `[LOGIC+UI]` 類型）：
      - 檢查此 action 對應的 test 檔案是否已存在
      - 若不存在且 plan.md 中有對應的 RED:test action 未完成 → 警告：「對應的測試 action [S0XX] 尚未完成，建議先執行測試 action」
      - 用戶可選擇繼續或先執行測試
   2. **識別此 action 支援的步驟定義**（來自 `[Verifies: @tag]`）
   3. **撰寫最小實作**使該步驟通過
   4. **執行情境** — 目標 **GREEN**
   5. **若 GREEN**：標記 action 完成，繼續下一個
   6. **若 RED**：除錯、修正、重跑直至 GREEN

   #### 重構階段：
   
   每個 story 的 actions 皆 GREEN 後：
   1. 檢視程式碼重複
   2. 套用適當 pattern
   3. 確保測試仍 GREEN
   4. 以 story 參照提交

   #### REFLECT Phase（Hard Gate — 不可跳過）:

   每個 action GREEN 後，**必須**進行 ≤ 30 秒的快速自檢：

   1. 發現了 codebase 慣例或 pattern？
   2. 踩到了陷阱或需要注意的事項？
   3. 做了需要記錄的技術決策？
   4. 做了涉及替代方案取捨的選擇？（→ Decision Log）
   5. 先前 insight 需修正？

   **Hard Gate 規則**：
   - REFLECT 是 **mandatory gate**，每個 action 完成後**必須**寫入 `TASK_DIR/insights.md`
   - **有新發現**：寫入 `- [S0XX] 發現內容`（歸入對應分類）
   - **無新發現**：寫入 `- [S0XX] No new insights`（證明已執行自檢）
   - 首次寫入時，從 `.teammate/templates/insights-template.md` 複製模板
   - **完成證據**：每個 action 回報時必須包含 `REFLECT: done`（或 `REFLECT: [N] insights`）
   - **禁止批次補寫**：不可在多個 action 完成後才一次補寫所有 REFLECT，必須逐 action 即時寫入

7. **各階段執行**：

   - **Setup Phase**：初始化專案、相依、設定
   - **Foundational Phase**：核心基礎設施（阻擋所有 stories）
   - **Story Phases**：依優先序，每個 user story 一 phase
     - 先寫步驟定義（RED）
     - 實作（目標 GREEN）
     - 必要時整合
   - **Polish Phase**：橫切關注點、文件

8. **平行執行規則**：

   標記 `[P]` 的 actions 可平行執行，若：
   - 修改不同檔案
   - 無相依於未完成的 actions
   - 驗證獨立情境

9. **進度追蹤**：

   每個 action 完成後：
   - 在 plan.md（Part 2: Actions）標記 `[x]`
   - 回報進度
   - 更新 `.teammate/memory/progress.md`

   失敗的 actions：
   - 回報錯誤與脈絡
   - 建議除錯步驟
   - 不繼續執行相依 actions

10. **完成驗證**：

    階段完成時：
    - 該 phase 所有 actions 已標記完成
    - 該 phase 所有情境皆 GREEN
    - 無失敗測試
    - 程式碼符合專案慣例

11. **Phase Completion Sync**（階段完成同步）:

    當一個 Phase 的所有 actions 都完成時，MUST 執行以下同步：

    1. **更新 `milestone.md`**：
       - 任務清單中該任務的 Status 更新為當前 Phase
       - Deliverables 反映已完成的產出
       - Metrics 更新（通過的 scenarios 數、action 完成率）

    2. **更新 `progress.md`**：
       - Current Phase 更新為下一個 Phase
       - Next Actions 列出下一 Phase 的第一個 action
       - 記錄已完成 Phase 的摘要

    > 此步驟確保 memory 與實際進度同步，避免任務清單仍顯示 Pending 的脫節問題。

12. **更新 Active Context**（Memory Delta Protocol）:

    以差量模式更新 `.teammate/memory/progress.md`：
    - **覆寫 `## Current State`**：Phase: Deliver, Last Command: execute [action ID], Next Action: [next action or /teammate.review]
    - **追加 `## Session Log`**：`| [timestamp] | execute [ID] | [GREEN/RED], [action description] | [insights discovered if any] |`
    - **更新 `## Blockers`**：如有 failing scenarios 或 Risk Gate 暫停，記錄為 blocker；已解決的標記 `[RESOLVED]`

13. **完成報告**：

    功能完成時：
    - 所有情境 GREEN
    - 所有 actions 完成
    - 活文件已更新
    - 建議下一步：`/teammate.review`

## Red-Green 迴圈紀律

### 為什麼先 RED？

先寫步驟定義再實作，可確保：
1. 撰寫程式前已理解行為
2. 有失敗測試引導實作
3. 明確知道何時完成（GREEN）
4. 避免過度設計

### 為什麼 REFLECT？

REFLECT 確保執行過程中的隱性知識被結構化保留：
1. Codebase 慣例不再靠 AI「下次記得」，而是寫在 `insights.md`
2. 跨 action 知識傳遞：後續 action 可參考先前 action 的 insights
3. 跨任務知識傳遞：Smart Context Loading 會載入最近任務的 insights
4. 決策軌跡可回溯：事後可追蹤 AI 選擇了什麼、為什麼

### 步驟定義範例

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

### 最小實作

僅撰寫足以使當前步驟定義通過的程式碼：
- 不加入尚未測試的功能
- 不提早優化
- 不處理情境中未涵蓋的邊界情況

### 安全重構

GREEN 之後：
- 萃取共用程式碼
- 改善命名
- 套用 pattern
- 每次變更後執行測試
- 全程保持 GREEN

### REFLECT 快速自檢（Hard Gate）

REFACTOR 之後：
- ≤ 30 秒的快速自檢，不是長篇報告
- **每個 action 必須寫入 `insights.md`**（有發現寫內容，無發現寫 `No new insights`）
- 記錄格式：`- [S0XX] 發現內容`
- 五個固定問題：慣例？陷阱？決策？取捨？修正？
- **禁止跳過、禁止批次補寫**

## 實作執行規則

- **先 Setup**：專案結構、相依
- **Foundation 先於 stories**：共用基礎設施
- **Stories 依優先序**：P1 → P2 → P3
- **步驟定義先於程式碼**：一律先 RED
- **每個 GREEN 後提交**：小步、可追溯的 commits

## 錯誤處理

若 action 失敗：
1. 回報錯誤與完整脈絡
2. 顯示失敗情境與步驟
3. 建議可能的修正方式
4. 等待使用者指示
5. 不繼續執行相依 actions

平行 actions：
- 繼續執行成功的 actions
- 回報失敗的 actions
- 使用者可選擇修正或略過
