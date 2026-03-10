---
description: 唯一品質關卡 — 行為覆蓋分析、功能就緒驗證、程式碼品質、安全掃描、測試健全度。設計維度委派 design-auditor，程式碼深度審查委派 code-auditor。
handoffs:
  - label: 修補缺口
    agent: teammate.plan
    prompt: 更新計畫以處理 review 發現
    send: true
---

## User Input

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量後再繼續。

## Outline

目標：對行為覆蓋、產物一致性與功能就緒進行**專業、中立**的分析。此為最終驗證關卡，整合行為審查與需求品質驗證於單次執行。

### 操作限制

**嚴格唯讀**：不得修改任何檔案，僅輸出結構化分析報告。

**原則權威**：專案原則（`.teammate/memory/principles.md`）**不可妥協**，原則衝突一律視為 CRITICAL。

**專業語氣**：客觀、建設性，適合團隊審查，禁止諷刺或煽動性用語。

### 階段 0：基礎檢查

1. **讀取 `.teammate/memory/context.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 的 placeholder token
   - 若發現 → **ERROR**："Project context not initialized. Run `/teammate.init` first."

2. **讀取 `.teammate/memory/principles.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 的 placeholder token
   - 若發現 → **ERROR**："Principles not defined. Run `/teammate.init` first."
   - **解析所有原則**：將每個 MUST / MUST NOT / SHOULD 規則及其 ID（如 `BB-001`、`III-D`）擷取至記憶體檢查清單，作為 Pass B3、Pass D Compliance、Pass G 的**權威參考**。

### 設定

從 repo root 執行 `skills/teammate/scripts/bash/check-prerequisites.sh --json --require-plan --include-plan`並解析：
- `TASK_DIR`、`AVAILABLE_DOCS`

推導路徑：
   - SPEC = `TASK_DIR/spec.md`
   - PLAN = `TASK_DIR/plan.md`（Part 1: Tasks + Part 2: Actions）
   - FEATURES = `TASK_DIR/scenarios/*.feature`
   - EXAMPLE_MAPPING = `TASK_DIR/example-mapping.md`
   - UI_SPEC = `TASK_DIR/contracts/ui/ui-spec.md`（若存在）
   - INSIGHTS = `TASK_DIR/insights.md`（若存在）

若必要檔案缺失則中止。

### 載入產物

   從 spec.md：使用者故事、功能需求、成功準則
   從 plan.md Part 1（Architecture）：技術決策、專案結構、約束
   從 plan.md Part 2（Actions）：含 [Verifies: @tag] 標記的 actions、階段結構
   從 scenarios/*.feature：所有含 tag 的場景、step 定義
   從 principles：原則與邊界

---

## Pass A：行為覆蓋分析

#### 場景類型分佈

| Type | Count | Percentage | Target |
|------|-------|------------|--------|
| @happy-path | [N] | [%] | 30-40% |
| @alternative | [N] | [%] | 20-30% |
| @negative | [N] | [%] | 20-30% |
| @boundary | [N] | [%] | 10-15% |
| @principles | [N] | [%] | 5-10% |

#### 使用者故事覆蓋率

| Story | Scenarios | Happy | Negative | Principles | Status |
|-------|-----------|-------|----------|------------|--------|
| US1 | [N] | [N] | [N] | [N] | [Complete/Gaps] |

#### 行為品質檢查

- 場景測的是 BEHAVIOR（做什麼）還是 IMPLEMENTATION（怎麼做）？
- Step 是宣告式還是命令式？
- 場景是否獨立（可單獨執行）？

#### 自動斷言產生（Test-Driven Review 強化）

根據 `spec.md` 的 **Success Criteria** 與 `example-mapping.md` 的 **P1 rules 邊界條件**，自動產生 3–5 個斷言樣本：

```ts
// 產生格式：尚未實作的可執行斷言骨架
// 總數控制在 3–5 個，對準 P1 Success Criteria 與核心邊界條件
describe('[feature]', () => {
  it('[Success Criteria 1]', () => { expect(/* 實作結果 */).toBe(/* 期望値 */); });
  it('[boundary: P1 rule 邊界]', () => { expect(/* 邊界狀態 */).toBe(/* 期望値 */); });
  it('[negative: 失敗情境]', () => { expect(/* 錯誤處理 */).toThrow(/* 預期錯誤 */); });
});
```

> **驗證機制**：若安裝測試框架（vitest/jest/pytest），將斷言寫入 `TASK_DIR/checklists/review-assertions.spec.ts`；否則僅輸出為準備執行的斷言樣本。實現代碼通過所有斷言，即視為 Review 通過。

## Pass B：一致性分析

#### B1. 追溯驗證
- 每個需求 → 場景 → actions → [Verifies: @tag]
- 回報缺口：無場景的需求、無 action 的場景、孤兒 actions

#### B2. 術語一致性
- 相同概念在不同檔案中命名是否一致？
- spec、model、scenarios 的實體名稱是否一致？

#### B3. Principles Alignment（逐條比對）

Using the principles checklist parsed in Phase 0, perform **item-by-item** verification:

1. **For each principle (MUST / MUST NOT / SHOULD)**:
   - Does it have at least one `@principles` or `@boundary` scenario in `*.feature`?
   - Does the implementation code comply? (spot-check relevant source files)
   - If the principle relates to accessibility (e.g. aria attributes, keyboard navigation), verify the **actual code** has the required attributes — do not assume compliance from scenario existence alone.
2. **Plan decisions alignment**: Do technical decisions in `plan.md` contradict any principle?
3. **Severity**: Any violation of a MUST / MUST NOT principle is automatically **CRITICAL**. Missing scenario coverage for a principle is at least **MEDIUM**.

Output a table:

| Principle ID | Statement (summary) | Scenario Coverage | Code Compliance | Status |
|---|---|---|---|---|

#### B4. Example Mapping 覆蓋
- example-mapping 的每條規則都有對應場景？
- 所有問題是否已解決？

#### B5. UI Contract 一致性（若存在 CONTRACTS）
- `contracts/ui/` 的元件名稱是否與 spec、tasks 一致？
- Props、routes、enhanced components 是否與 plan.md 架構一致？
- 回報術語漂移

## Pass C：偵測掃描

#### 重複偵測
- 相似場景測同一行為？冗餘的 step 定義？

#### 模糊偵測
- 場景名稱含糊？Step 用語不清？

#### 規格不足
- 場景缺少 Then 斷言？Step 結果不明確？

#### 實作洩漏
- 場景描述 HOW 而非 WHAT？業務場景出現技術術語？

## Pass D：需求品質驗證

> 整合原 `/teammate.checklist` 的需求品質檢核功能。

#### 完整性
- 所有必要需求是否已記錄？
- 各失敗模式是否定義錯誤處理需求？
- 是否指定無障礙需求？

#### 清晰度
- 需求是否具體且無歧義？
- 模糊用語是否以具體準則量化？
- 成功指標是否可量測？

#### 一致性
- 需求之間是否無衝突？
- 功能內模式是否一致？

#### 覆蓋
- 所有場景／邊界情況是否涵蓋？
- 邊界條件是否定義？
- 負向路徑是否指定？

#### Compliance Coverage（委派 design-auditor）

從 `plan.md` 讀取 System Scope 表格，當 Frontend/LLM/Mobile 標記為 ✅ 時，委派 `design-auditor` agent 執行設計合規檢查（A11y、AI Risk、Design System Compliance）。

若使用者專案未安裝 design 分類的 skills，跳過並在報告中標註「設計品質審查未啟用」。

## Pass E：追溯矩陣

建立從行為到實作的追溯：

| Scenario | Rule | Action(s) | Status |
|----------|------|-----------|--------|
| @us1-login-success | Rule 1 | S012-S015 | [Pass/Fail/Pending] |

標示缺口：無 action 的場景、無場景的 actions、無範例的規則。

## Pass F：活文件

依 `skills/teammate/references/review-report-format.md` 的格式規範，產生 `TASK_DIR/checklists/feature-readiness.md`。

---

## 嚴重度分級

- **CRITICAL**：原則違反、P1 場景覆蓋缺失、需求品質 < 60%
- **HIGH**：重複場景、模糊需求、P2 覆蓋缺口
- **MEDIUM**：術語漂移、輕微覆蓋缺口、不明確的 step
- **LOW**：樣式改進、優化機會

## 功能就緒關卡

| 關卡 | 準則 | 阻擋？ |
|------|------|--------|
| 需求品質 | 各維度 > 80% | Yes |
| Happy Path 覆蓋 | P1 stories 100% | Yes |
| 負向覆蓋 | 每 story 至少 1 個 | Yes |
| Principles 覆蓋 | 至少 1 個 boundary | Yes |
| 追溯 | 所有場景連結至 actions | No |
| 未解決問題 | 無 CRITICAL/HIGH | Yes |

## 下一步行動

依發現結果：
- CRITICAL：必須先解決才能繼續 → 建議 `/teammate.plan update`
- HIGH：應處理以提升品質 → 建議具體修復
- 僅 LOW/MEDIUM：可繼續 → commit → checkout main → merge

### 任務結束且無需修正時（務必執行）

當 **Readiness: Ready** 且 **無 CRITICAL/HIGH 待修**（或使用者已決定不修）時，**必須**在報告結尾詢問使用者：

```
是否要 commit 並 merge 回 main？

- 若要：請在 **Agent 模式**下請我代為執行 commit（目前分支）→ `git checkout main` → `git merge <當前 task 分支>`。
- 若否：可稍後自行依流程 commit 後再 merge。
```

不代為執行 Git 指令（review 為唯讀）；僅提示流程：**Review 完成 → commit → checkout main → merge**。

## Pass G：目標對齊（永遠啟用）

| 檢查項 | 方法 |
|--------|------|
| 產品目標覆蓋 | `context.md` Business Goals 中的每個目標，是否有對應的實作？ |
| 里程碑一致性 | `milestone.md` 的 Deliverables 與實際產出是否吻合？ |
| 多餘實作 | 是否有不在目標或里程碑中的功能被實作？ |

## Pass H：安全掃描（永遠啟用）

| 檢查項 | 方法 |
|--------|------|
| SQL/NoSQL Injection | 搜尋直接字串拼接查詢 |
| XSS | 搜尋 `dangerouslySetInnerHTML`、`innerHTML`、未轉義輸出 |
| 硬編碼密鑰 | 搜尋 API key / token / secret 字串 |
| 未驗證輸入 | 搜尋未經 sanitize 的使用者輸入直接使用 |

## Pass I：程式碼品質（永遠啟用）

| 檢查項 | 方法 |
|--------|------|
| 命名品質 | 搜尋單字母變數（非迴圈索引）、含糊命名（`data`、`temp`、`info`） |
| 函式大小 | 偵測超過 30 行的函式、參數超過 3 個的函式 |
| DRY 違規 | 搜尋相似邏輯片段、複製貼上痕跡 |
| SRP 違規 | 偵測承擔過多職責的 class/module |
| 錯誤處理 | 搜尋空 catch block、未處理的 Promise rejection |
| 副作用 | 搜尋隱藏的全域狀態變更、非純函式的意外修改 |
| 深層巢狀 | 偵測超過 3 層的條件巢狀 |
| 循環依賴 | 偵測模組間的循環 import |

## Pass J：測試健全度（永遠啟用）

| 檢查項 | 方法 |
|--------|------|
| 新程式碼覆蓋 | 新增/修改的程式碼是否有對應測試？ |
| 行為 vs 實作 | 測試是否驗證行為（what）而非實作（how）？ |
| 邊界案例 | 關鍵邏輯是否有邊界條件測試？ |
| Flaky 模式 | 搜尋 `setTimeout` in test、未 await 的非同步、依賴執行順序 |
| Mock 過度 | 是否 mock 了被測對象本身的行為？ |

## Pass K：設計品質（委派 design-auditor）

從 `plan.md` 讀取 System Scope 表格。當 Frontend/LLM/Mobile 標記為 ✅ 時：

1. 委派 `design-auditor` agent 執行設計維度審查
2. design-auditor 回傳結構化報告（UX、A11y、設計債務、AI 風險、Design System Compliance）
3. 將結果整合進最終 review 報告

若使用者專案未安裝 design 分類的 skills（`.teammate/config/skills.yml` 中無 design），跳過並在報告中標註「設計品質審查未啟用（未安裝設計 skills）」。

## Pass L：程式碼深度審查（委派 code-auditor）

委派 `code-auditor` agent 對 Pass H/I/J 進行深度補強審查：

1. 委派 `code-auditor` agent 執行多維度程式碼審查（安全漏洞、效能瓶頸、架構合規、程式碼品質、測試健全度）
2. code-auditor 載入 `code-review`、`ai-review-pipeline`、`code-refactoring` skills 進行深度分析
3. code-auditor 回傳結構化報告，將結果整合進最終 review 報告

若使用者專案未安裝 code-auditor 相關 skills，跳過並在報告中標註「程式碼深度審查未啟用（未安裝 code-auditor skills）」。Pass H/I/J 的基礎檢查仍正常執行。

## Update Progress

更新 `.teammate/memory/milestone.md`：任務驗證狀態、覆蓋率指標、就緒評估。

## Update Active Context

依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
- **Current State 專屬欄位**：Readiness: [status], Phase: Deliver, Last Command: review, Next Action: [recommended command]
- **Session Log**：`| [timestamp] | review | [N] critical, [N] high, Readiness: [status] | [recommendation] |`
- **Blockers**：如有 CRITICAL findings，記錄為 blocker

## Report Completion

Output:
- Path to `feature-readiness.md`
- Executive summary (2-3 sentences)
- Critical/High findings count
- Readiness status
- Recommended next steps
- Suggested next command
- **Scenario → Assert 追湯表**：列出每個 P1 Scenario 對應的斷言樣本 ID，與通過/未通過狀態

  | Scenario Tag | 對應斷言 | 狀態 |
  |---|---|---|
  | @us1-happy-path | `review-assertions.spec.ts#L12` | Pass / Fail / Pending |

**當 Readiness 為 Ready 且無需修正時**：必須在輸出結尾加上「是否要 commit 並 merge 回 main？」的詢問（見「任務結束且無需修正時」）。

## 分析指引

### 行為 vs 實作

**佳**："User sees confirmation message"、"Order is placed successfully"
**不佳**："API returns 200 status"、"Database record is created"

### 專業語言

**使用**："This scenario could be enhanced with..."、"Consider adding coverage for..."
**避免**："This is wrong"、"You forgot to..."

### 覆蓋率目標

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| P1 Happy Path | 100% | 100% |
| P1 Negative | 50%+ | 25% |
| Principles | 100% | 80% |
| Overall | 80%+ | 60% |

## 操作原則

- **絕不修改檔案**（唯讀分析）
- **絕不臆測**（僅回報實際發現）
- **原則優先**（違反一律為 CRITICAL）
- **建設性**（每項發現附建議）
- **具體**（標註確切位置與問題）
