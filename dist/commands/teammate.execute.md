---
description: 執行 Red-Green-Verify-Reflect-Dialogue 迴圈實作 — 先寫步驟定義（RED），再實作至 GREEN，自動驗證（VERIFY），重構（REFACTOR），自檢（REFLECT），對話式同步（DIALOGUE），依 Actions 順序進行。
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

1. 讀取 `TASK_DIR/plan.md` Part 2，找到第一個 `- [ ]` action
2. 跳過所有 `- [x]`
3. 顯示：「**執行 S0XX**: [action 描述]」→ 進入 Red-Green Loop
4. 完成後標記為 `- [x]`，報告下一個待執行 action

### 迴圈總覽

```
RED → GREEN → VERIFY → REFACTOR → REFLECT → DIALOGUE → REPEAT
```

### 執行步驟

1. **Setup**：從 repo 根目錄執行 `skills/teammate/scripts/bash/check-prerequisites.sh --json --require-plan --include-plan`並解析 `TASK_DIR`、`AVAILABLE_DOCS`。
   - 參數含單引號時使用 escape 語法：`'I'\''m Groot'`

2. **檢查清單狀態**（若 `TASK_DIR/checklists/` 存在）：掃描所有 checklist 檔案，統計完成/未完成。若有未完成 → 暫停詢問；全部完成 → 自動繼續。

3. **載入實作脈絡**：

   **Staleness Check**：若 `spec.md` 比 `plan.md` 新 → 警告 plan 可能過期，建議先 `/teammate.plan update`。

   **必載**:
   - `plan.md` — Part 1（架構）+ Part 2（Actions）
   - `scenarios/*.feature` — Gherkin 情境

   **條件必載**（存在即載入，不得跳過）:
   - `TASK_DIR/insights.md` + 最近 2 個已完成任務的 `insights.md`
   - `.teammate/memory/agent-spec.md`
   - `docs/llms.txt` → 載入對應 `docs/[library]/llms.txt`
   - `contracts/` — API / UI / AI 合約

   **Compliance Skills**（動態偵測）:
   - 前端 → 載入 `a11y-compliance/SKILL.md`
   - AI/LLM → 載入 `ai-compliance/SKILL.md`

   **輔助參考**: `data-model.md`、`research.md`

   > **反簡短偏差**：條件必載資源不得以「節省 context」為由跳過。足夠重要的 insight 會「畢業」到 `context.md`。

4. **專案設定驗證**：依偵測到的技術建立/驗證 ignore 檔案（`.gitignore`、`.dockerignore` 等）。

5. **解析計畫結構**：從 `plan.md` Part 2 擷取 Phases、Actions、`[Verifies: @tag]`、`[P]` 平行標記、Action 類型。

6. **Risk-Based HITL Gates**（風險暫停）:

   在執行每個 action 前，檢查以下風險條件。觸發時暫停並詢問用戶：

   | 風險觸發條件 | 暫停行為 |
   |-------------|---------|
   | 涉及 `@principles` tag 或修改 Principles 邊界程式碼 | 確認繼續？ |
   | 需刪除或重命名檔案 | 確認刪除/重命名？ |
   | 修改共用基礎設施（config、shared utils、store、layout） | 確認影響範圍？ |
   | 引入 codebase 中不存在的新 pattern | 確認使用新 pattern？ |

   用戶可回覆「繼續」或「調整」。暫停事件記錄到 `progress.md`。

7. **執行 Red-Green 迴圈**：

   #### Action 類型偵測

   | 類型 | RED 階段 | GREEN 階段 |
   |------|---------|-----------|
   | `[DESIGN]` | spec.md Acceptance Scenarios（視覺驗證清單） | 設計稿修改（Pencil / Figma）+ 截圖驗證 |
   | `[LOGIC]` | 寫 unit test（期望 RED） | 寫最小實作讓 test GREEN |
   | `[UI]` | **智能分流**（見下方） | 實作 UI 組件 |
   | `[LOGIC+UI]` | 寫 unit test + 智能分流 | 實作邏輯 + UI |

   > 若 action 無類型標記，依描述推斷：.pen/.figma/設計關鍵字 → `[DESIGN]`；model/store/service/util → `[LOGIC]`；.svelte/.tsx/.vue → `[UI]`；兩者皆有 → `[LOGIC+UI]`。

   #### UI 智能分流

   - **有 Figma link 或兄弟組件可參考** → 直接實作
   - **有不確定的細節** → 使用 `AskQuestion` tool 暫停提供結構化選項
   - **完全無參考** → 完整暫停，展示視覺規格確認後再實作

   推斷依據：`contracts/ui/`、`principles.md`、`insights.md` 記錄的兄弟組件慣例。

   #### 若 Action 為步驟定義：

   1. 從 `.feature` 讀取情境（使用 `[Verifies: @tag]`）
   2. 撰寫步驟定義對應 Gherkin 步驟
   3. 執行情境 — 預期 **RED**
   4. 若 RED → 標記進行中，繼續實作；若 GREEN → 警告需驗證正確性

   #### 若 Action 為實作：

   1. **Test Pre-Check**（`[LOGIC]`/`[LOGIC+UI]`）：檢查對應 test 是否存在，若不存在且 RED action 未完成 → 建議先執行
   2. 識別此 action 的 `[Verifies: @tag]`
   3. 撰寫最小實作使步驟通過

   4. **VERIFY 階段**：

      a. 讀取 `teammate.yml` 的 `verification.test_command`（若為 null 則自動偵測框架）

      b. **首次確認**（僅本 task 第一次 VERIFY）：檢查 `progress.md` 是否已記錄 `test_command_confirmed`。若未記錄 → `[A]` 確認 / `[B]` 修改 / `[C]` 跳過

      c. 執行對應 scenarios（從 `[Verifies: @tag]` 提取 tag 組成指令）

      d. **判斷結果**：
         - **GREEN（exit 0）**：✅ 標記通過 → 進入 REFACTOR
         - **RED（exit 1）**：❌ 解析失敗步驟 → `[A]` 除錯實作 / `[B]` 修正 scenario / `[C]` 查看日誌 → 進入除錯循環
         - **環境錯誤（exit ≠ 0/1）**：⚠️ 提示環境問題 → `[A]` 修正環境 / `[B]` 手動指定指令 / `[C]` 跳過驗證

      e. 記錄到 `progress.md` Session Log：`| [timestamp] | execute [ActionID] | [GREEN/RED] @tag ([duration]) | [status] |`

   #### REFACTOR 階段

   每個 story 的 actions 皆 GREEN 後：檢視重複 → 套用 pattern → 確保測試仍 GREEN → 以 story 參照提交。

   #### REFLECT Phase（Hard Gate — 不可跳過）

   每個 action GREEN 後，**必須**進行 ≤ 30 秒快速自檢：

   1. codebase 慣例或 pattern？
   2. 陷阱或注意事項？
   3. 需記錄的技術決策？
   4. 涉及替代方案取捨？（→ Decision Log）
   5. 先前 insight 需修正？
   6. 此 insight 是否在 3+ 個任務中重複出現？（→ 建議畢業至 `context.md` 或 `principles.md`，見 `@teammate` 洞察畢業機制）

   **規則**：
   - 每個 action **必須**寫入 `TASK_DIR/insights.md`（有發現寫內容，無發現寫 `No new insights`）
   - 格式：`- [S0XX] 發現內容`；首次寫入時從模板複製
   - 完成證據：回報時包含 `REFLECT: done`
   - **禁止批次補寫**
   - **迭代追蹤**：已完成 action 因使用者回饋或錯誤修正而再次修改時，MUST 在 `insights.md` 對應段落追加迭代紀錄（修正原因、根本原因、教訓）；涉及新設計決策或新問題則新增 D-0XX 段落

   #### DIALOGUE Phase（對話式同步）

   REFLECT 完成後，執行語意差異偵測。**最小干預原則**：僅「超出計畫」或「結構性變更」才對話。

   ##### 觸發判斷

   | REFLECT 分類 | Verifies 範圍比對 | 新層級偵測 | DIALOGUE |
   |-------------|------------------|-----------|---------|
   | No insights / 重構 | — | 無 | **跳過** |
   | 新功能 | 在範圍內 | 無 | **跳過** |
   | 新功能 | **超出範圍** | — | **觸發（行為）** |
   | 任何 | — | **有** | **觸發（層級）** |

   ##### 行為範圍比對（dialogue_signal == "CHECK" 時）

   比對「action 實際實作的 public 介面」vs「[Verifies: @tag] 對應 scenario 涵蓋的行為」：
   - 掃描新增的 API endpoints、UI props、public 函式、驗證規則、錯誤處理、資料欄位
   - 核心判斷：實作是否超出 Verifies tag 涵蓋的行為範圍？

   ##### 系統層級偵測（永遠執行）

   掃描新增的 imports/files，比對 `plan.md` System Scope：
   - 若引入未標記的層級（如 `openai` import 但 LLM 為 ❌）→ 觸發層級對話

   ##### 層級變更對話

   若偵測到新層級 → 使用 `AskQuestion` tool 確認：
   - **確認**：更新 `plan.md` System Scope + Compliance Requirements + `spec.md` Change Log + `progress.md`
   - **取消**：記錄到 `insights.md` Technical Debt

   ##### 行為變更對話

   若超出 Verifies 範圍 → 提供選項：
   - `[A]` **刻意擴展** — 更新 `spec.md` FR + Change Log + `plan.md` 對應 action 標註 → 建立 snapshot
   - `[B]` **範疇蔓延** — 移除實作，標記 `[REVERTED]`
   - `[C]` **稍後處理** — 記錄到 `insights.md` Technical Debt
   - `[D]` **忽略差異** — 視為實作細節，不更新

8. **平行執行規則**：標記 `[P]` 的 actions 可平行執行，若修改不同檔案、無相依、驗證獨立情境。

9. **進度追蹤**：每個 action 完成後在 `plan.md` 標記 `[x]`、回報進度、更新 `progress.md`。失敗時回報錯誤，不繼續執行相依 actions。

10. **Phase Completion Sync**：Phase 所有 actions 完成時，更新 `milestone.md`（Status、Deliverables、Metrics）與 `progress.md`（Phase、Next Actions、Phase 摘要）。

11. **Update Active Context**：依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
    - **Current State**：Phase / Task / Last Command: execute [ID] / Next Action
    - **Session Log**：`| [timestamp] | execute [ID] | [GREEN/RED], [description] | [insights] |`
    - **Blockers**：failing scenarios 或 Risk Gate 暫停

12. **完成報告**：所有情境 GREEN + actions 完成 + 活文件已更新 → 建議 `/teammate.review`

## 實作執行規則

- **先 Setup**：專案結構、相依
- **設計先於程式**：`[DESIGN]` actions 完成後才執行同 story 的 `[UI]`/`[LOGIC]` actions
- **Foundation 先於 stories**：共用基礎設施
- **Stories 依優先序**：P1 → P2 → P3
- **步驟定義先於程式碼**：一律先 RED
- **每個 GREEN 後提交**：小步、可追溯的 commits

## 錯誤處理

若 action 失敗：回報錯誤與完整脈絡 → 顯示失敗情境與步驟 → 建議修正方式 → 等待使用者指示 → 不繼續執行相依 actions。

平行 actions：繼續成功的 → 回報失敗的 → 使用者可選修正或略過。
