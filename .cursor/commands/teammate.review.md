---
description: 執行行為覆蓋分析與功能就緒驗證，整合 review 與 checklist 為單一品質關卡。
handoffs:
  - label: 建立 Issues
    agent: teammate.helpme
    prompt: assign — 將 actions 轉為 GitHub Issues
    prompt: 將任務轉為 GitHub issues
    send: true
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

從 repo root 執行 `.teammate/scripts/bash/check-prerequisites.sh --json --require-plan --include-plan` 並解析：
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

#### Compliance Coverage（動態，偵測到才執行）

掃描 `context.md` tech stack + codebase 偵測前端/AI 特性：

**A11y**（偵測到前端 UI 時）:
- 所有互動 UI 元件是否有適當的 aria 屬性？
- 鍵盤導航是否覆蓋所有功能？
- 色彩對比是否達 WCAG 2.2 AA 標準？
- 表單是否有錯誤提示與 `aria-invalid`？

**AI Risk**（偵測到 LLM/AI 時）:
- AI 互動是否有首次揭露機制？
- AI 生成內容是否有標示（可見 + 機器可讀）？
- 同意流程是否具同等視覺顯著性？
- 高風險決策是否有人類覆寫機制？

> 此為初步檢查。完整對抗性審計請執行 `/teammate.audit`。

## Pass E：追溯矩陣

建立從行為到實作的追溯：

| Scenario | Rule | Action(s) | Status |
|----------|------|-----------|--------|
| @us1-login-success | Rule 1 | S012-S015 | [Pass/Fail/Pending] |

標示缺口：無 action 的場景、無場景的 actions、無範例的規則。

## Pass F：活文件

產生 `TASK_DIR/checklists/feature-readiness.md`：

```markdown
# Feature Readiness Report: [Feature Name]

**Generated**: [Date]
**Status**: [Ready/Not Ready/Partial]

## Executive Summary
[2-3 sentence overview]

## Behavioral Coverage
[Scenario distribution + coverage by story]

## Requirements Quality
| Dimension | Score | Issues |
|-----------|-------|--------|
| Completeness | [%] | [N] |
| Clarity | [%] | [N] |
| Consistency | [%] | [N] |
| Coverage | [%] | [N] |

## Findings
| ID | Category | Severity | Location | Finding | Recommendation |
|----|----------|----------|----------|---------|----------------|

## Traceability Summary
[Matrix from Pass E]

## Principles Compliance
| Principle | Coverage | Status |
|-----------|----------|--------|

## Metrics
- Total Scenarios: [N]
- Total Actions: [N]
- Scenario Coverage: [%]
- Principles Coverage: [%]
- Critical Issues: [N]

## Recommendation
[Ready to proceed / Needs attention / Blocked]
```

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
- 僅 LOW/MEDIUM：可繼續 → 建議 `/teammate.helpme assign`

## Pass G: Design System Compliance（偵測到前端才啟用）

若 Phase 1 偵測到前端 UI 代碼，執行以下檢查：

#### Token 合規
- 搜尋硬編碼顏色值（`#[0-9a-fA-F]{3,8}` 且非在 token 定義檔中）
- 搜尋硬編碼間距值（`margin: Npx`、`padding: Npx` 等非 token 值）
- 統計 Token 覆蓋率：使用 design token 的樣式 vs 硬編碼值

#### 視覺一致性
- 偵測非 Token 樣式（原生 px 值、inline style）
- 品牌調性一致性（字體、圓角、陰影是否使用統一 token）

#### 輸出

```markdown
### Design System Compliance

| 檢查項 | 狀態 | 數量 |
|--------|------|------|
| 硬編碼顏色值 | [PASS/FAIL] | [N] |
| 硬編碼間距值 | [PASS/FAIL] | [N] |
| Token 覆蓋率 | [%] | — |
```

> 完整 Design Debt 審計請執行 `/teammate.audit design-debt`。

## Update Progress

更新 `.teammate/memory/milestone.md`：任務驗證狀態、覆蓋率指標、就緒評估。

## Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/progress.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Deliver, Last Command: review, Next Action: [recommended command]
- **追加 `## Session Log`**：`| [timestamp] | review | [N] critical, [N] high, Readiness: [status] | [recommendation] |`
- **更新 `## Blockers`**：如有 CRITICAL findings，記錄為 blocker

## Report Completion

Output:
- Path to `feature-readiness.md`
- Executive summary (2-3 sentences)
- Critical/High findings count
- Readiness status
- Recommended next steps
- Suggested next command

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
