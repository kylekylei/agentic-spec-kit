---
description: 一次產出 Gherkin 場景與統一實作計畫（任務 + 行動）。產物：.feature 檔 + plan.md + contracts/ui/ui-spec.md（若有 UI）。
handoffs: 
  - label: 執行行動
    agent: teammate.execute
    prompt: 啟動 Red-Green Loop 實作
    send: true
  - label: 審查覆蓋率
    agent: teammate.review
    prompt: 執行前先進行行為覆蓋率分析
    send: true
---

## 使用者輸入

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**先考量其內容再繼續。

## 流程概覽

目標：將已對齊的 spec 與範例轉為完整執行計畫 — **Gherkin scenarios**（驗證 WHAT）與統一 **plan.md**（含技術任務 HOW 與原子行動 STEPS）。

### 模式偵測

解析 `$ARGUMENTS` 關鍵字：

- `update` → **Update Mode**（保留既有產物、變更前快照、以 `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]` 標記）
- `--ui` → **強制 UI 深度分析**（即使 < 3 個 UI 組件）
- 其他 → **Create Mode**（預設；若 ≥ 3 個 UI 組件則自動觸發 UI Deep Analysis）

### 階段 0：基礎檢查

1. **讀取 `.teammate/memory/context.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 的 placeholder token
   - 若發現 → **ERROR**：「專案脈絡未初始化，請先執行 `/teammate.init`。」

2. **讀取 `.teammate/memory/principles.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 的 placeholder token
   - 若發現 → **ERROR**：「原則未定義，請先執行 `/teammate.init`。」

### 更新模式

以 `update` 執行時，指令會保留既有產物：

1. **變更前快照**：複製既有 `plan.md`、`scenarios/*.feature` 至 `.teammate/snapshots/`
2. **詢問使用者**：「變更內容與原因？」（一行）
3. **差異感知處理**：比對基準與當前 spec/examples
4. **標記變更**：`[UNCHANGED]`、`[NEW]`、`[REVISED]`、`[REMOVED]`
5. **同步合約**（若存在 `contracts/ui/`）：更新 `ui-spec.md` 中過期項目
6. **影響報告**：統計未變更/新增/修訂/移除數量
7. **不丟棄已完成工作** — 移除項目改為註解，不刪除

---

## 階段 1：場景生成

> 產出：`TASK_DIR/scenarios/*.feature` + `teammate.refs.yaml`

### 設定

1. 從 repo 根目錄執行 `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only`，解析 JSON 取得 `TASK_DIR`、`TASK_SPEC`。

2. **載入脈絡**：

   Required:
   - `TASK_DIR/spec.md` — 使用者故事與需求
   - `TASK_DIR/example-mapping.md` — 規則與範例
   - `.teammate/memory/principles.md` — 不可妥協的邊界

   Optional:
   - `.teammate/templates/feature-template.feature` — Gherkin 模板
   - `TASK_DIR/contracts/ui/design-principles.md` — UX 設計原則

3. **建立場景目錄**：`mkdir -p TASK_DIR/scenarios`

### UX 衝突掃描（若存在 `design-principles.md`）

在產生 scenarios 之前，強制執行設計原則衝突分析：

1. **設計原則 vs 核心原則交叉比對**: API 可行性、是否需新增後端 endpoint
2. **互動元素可行性檢查**: 每個 UI action 需要的後端能力是否存在
3. **參考設計語意差異**: 外部參考產品的操作語意 vs 本專案操作語意
4. **Conflict Report**: 有 CONFLICT 或 SEMANTIC_GAP 時暫停讓使用者決策

### 場景生成

依優先序處理每個 User Story：

1. **產生 `.feature` 檔**：含標頭、Background、已標籤 Scenarios
2. **對應 Example Mapping**：規則 → scenarios，範例 → Given/When/Then
3. **加入 Principles 邊界場景**（`@principles @boundary`）
4. **合併資料驅動場景**：適用處使用 Scenario Outline
5. **寫入** `TASK_DIR/scenarios/[story-slug].feature`

### 脈絡錨點

建立/更新 `TASK_DIR/teammate.refs.yaml`，含任務中繼資料、行為參照與依賴。

### 覆蓋率驗證

要求：每條規則 → 至少一個 scenario。每個 P1 story → happy path + negative。每個 principles 邊界 → 一個 scenario。

### Gherkin 品質檢查

- 每個 scenario 獨立（可單獨執行）
- 步驟為宣告式（WHAT，非 HOW）
- 步驟中不含實作細節
- 標籤遵循慣例（@P1/@P2/@P3、@happy-path 等）

---

## 階段 2：實作計畫 — Part 1：架構

> 產出：`TASK_DIR/plan.md` 的 Part 1（技術架構）

### 載入額外脈絡

Optional（如存在則載入）:
- `.teammate/memory/agent-spec.md` → AI Agent 行為規範（如專案有 AI Agent 角色）
- `docs/llms.txt` → 外部 API/SDK 參考索引（遵循 llms.txt 標準）
- `TASK_DIR/example-mapping.md`

### 設計資產偵測（動態）

檢查 `.teammate/design/figma-index.md` 是否存在：

- **If exists** → UI Deep Analysis **必定觸發**（無需滿足 ≥3 組件條件）
  1. Load as design context
  2. Append current feature page link to `figma-index.md` Feature Pages table (if user provides)
  3. **Enable `contracts/ui/ui-spec.md` generation** in Stage 2.5
- **If not exists** → 僅在 `--ui` flag 或 ≥3 UI 組件時觸發 UI Deep Analysis

### Compliance Detection（動態）

掃描 `context.md` tech stack + codebase 自動偵測：

1. **前端偵測**（*.tsx/*.vue/*.svelte/*.html 或 react/vue/svelte 依賴）→ 在 Architecture 區段標記：
   > ⚠️ **A11y Compliance 已啟用**：所有 UI 組件需符合 WCAG 2.2 AA。建議為每個互動元素規劃 aria 屬性、鍵盤導航與色彩對比。參考 `.cursor/skills/a11y-compliance/SKILL.md`。

2. **AI/LLM 偵測**（openai/anthropic/langchain import 或 chat/completion API）→ 在 Architecture 區段標記：
   > ⚠️ **AI Risk Compliance 已啟用**：AI 互動介面需符合 EU AI Act Art. 50 透明度義務。建議規劃 AI 揭露標籤、同意機制、內容標示、人類覆寫控制。參考 `.cursor/skills/ai-compliance/SKILL.md`。

若 context.md 無標記但 codebase 偵測到 → 額外提示更新 context.md。

### 測試基礎設施檢查

1. **檢查既有測試框架**：掃描 `package.json` (vitest/jest/playwright)、`pytest.ini`、`go.mod` 等
2. **若不存在**：在 plan.md 新增 Phase 0 必要 setup（測試框架設定、測試目錄、mock setup）
3. **若已存在**：記錄在 Technical Context 中

### 技術規劃

1. **Technical Context**：語言/版本、依賴、儲存、測試框架、約束
2. **Principles Check**：將每條原則對應到技術決策。*GATE：必須通過*
3. **Actors & Abilities**（選用，≥5 stories）：從 scenarios 識別 actors，定義角色、能力、關鍵任務
4. **Project Structure**：原始碼結構與檔案標記：
   - `[NEW]` — 待建立的新檔
   - `[ENHANCE]` — 既有檔，有功能變更
   - `[INTEGRATE]` — 既有檔，需 import/mount [NEW] 組件（純接線）

### 整合影響分析

對每個 `[NEW]` 組件，識別其 **consumer**（需 import/mount 的既有檔）：
- 每個 `[NEW]` UI 組件（非其他 [NEW] 的子組件）MUST 至少有一個 `[INTEGRATE]` consumer
- 常見整合點：layout 檔（全域）、page 檔（路由專屬）、父組件

### 研究與決策

若有 NEEDS CLARIFICATION 項目：產生研究任務，彙整於 plan.md Research 區段。

---

## 階段 2.5：UI 深度分析（自動觸發或 --ui）

> 產出：`TASK_DIR/contracts/ui/ui-spec.md`（統一 UI 規格）

**觸發條件**（滿足任一）:
1. `.teammate/design/figma-index.md` 存在（表示專案有設計資產）
2. spec.md + Project Structure 中 `[NEW]`/`[ENHANCE]` UI 組件數量 ≥ 3
3. 使用者指定 `--ui` flag

> 若無 `figma-index.md` 且未達觸發條件，此階段跳過，不產生 `contracts/ui/ui-spec.md`。

### 組件清單

掃描 spec.md 和 plan.md Project Structure，列出所有 UI 組件：

| 組件 | 類型 | 狀態數 | 父組件 | 備註 |
|------|------|--------|--------|------|
| [ComponentA] | [Panel/Card/...] | [N] | [parent] | [notes] |

### 屬性與介面

每個組件：Props、匯出介面、關鍵事件、slot 結構。

### 狀態矩陣

為每個組件定義完整視覺狀態：

| 狀態 | 觸發條件 | 外觀描述 | 互動行為 |
|------|----------|----------|----------|

Rules:
- 每個組件 MUST 至少 3 種狀態（預設 + 主要 + 邊界）
- Loading/Error/Empty 狀態 MUST 說明內容和使用者動作

### 互動流程

將核心互動路徑（happy path + error path）定義為步驟序列。

### 互動狀態機

對每個互動元素：

| 元素 | 觸發條件 | 狀態 | 行為 |
|------|----------|------|------|

Rules: 每個互動元素 MUST 有 enabled + disabled；若引用外部設計 MUST 標註語意差異。

### 設計系統合規

- UI：color tokens、spacing scale、typography
- i18n：所有可見文字使用 i18n key，同步至所有語系
- a11y：aria-label、鍵盤導航、focus 管理、對比 ≥ 4.5:1

全部寫入 `TASK_DIR/contracts/ui/ui-spec.md`。

---

## 階段 3：實作計畫 — Part 2：行動

> 產出：`TASK_DIR/plan.md` 的 Part 2（執行清單）

### 提取場景標籤

解析所有 `.feature` 檔，建立 tag 清單。

### 依使用者故事生成行動

#### 行動格式

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

- `[Type]`: **REQUIRED** — `[LOGIC]`, `[UI]`, or `[LOGIC+UI]`
- RED/GREEN Forced Split: `[LOGIC]` 涉及 util/store/service/model MUST 拆為 RED + GREEN 兩個 actions
- `[UI]` 不強制拆分

#### 整合行動

對 Part 1 Project Structure 中每個 `[INTEGRATE]` 檔，在組件建立 action 之後立即產生 mount/import action。

### 階段結構

- **Phase 0: Setup** — 專案初始化、測試基礎設施
- **Phase 1: Foundational** — 核心基礎設施
- **Phase 2+: User Stories** — 故事專屬行動（先 step definitions，再實作）
- **Phase N: Polish** — 橫切關注點

### 追溯矩陣

| Scenario Tag | Actions | Status |
|--------------|---------|--------|

覆蓋率：[X]/[Y] scenarios ([Z]%)

### 寫入 plan.md

將完整計畫（Part 1 + Part 2）寫入 `TASK_DIR/plan.md`，使用 `.teammate/templates/plan-template.md`。

---

## 最後步驟

### 更新現用脈絡（Memory Delta Protocol）

以 delta 模式更新 `.teammate/memory/progress.md`：
- **覆寫 `## Current State`**：Phase: Commit (complete), Last Command: plan, Next Action: /teammate.execute
- **追加 `## Session Log`**：`| [timestamp] | plan | [N] scenarios, plan.md ([N] tasks, [N] actions), [coverage]% | [key decisions] |`

### 完成報告

輸出：
- 產出檔案清單（`.feature`、`plan.md`、`contracts/ui/ui-spec.md` 若觸發）
- 場景摘要：[N] 個 scenarios，跨 [N] 個 stories
- 計畫摘要：Part 1 Architecture（[N] 個技術決策）、Part 2 Actions（[N] 個 actions，[coverage]%）
- 已識別的並行機會
- 建議下一步：`/teammate.execute`

---

## Gherkin 撰寫指引

### 標籤慣例

```gherkin
@feature-name @P1           # Feature 與優先序
@happy-path                  # 主要成功路徑
@alternative                 # 有效替代流程
@negative                    # 錯誤/失敗場景
@boundary                    # 邊界與極限
@principles                  # 原則邊界強制
@data-driven                 # 參數化場景
```

### 步驟撰寫最佳實踐

**Given** — 脈絡/狀態：「Given the user is logged in」
**When** — 動作：「When the user submits the form」
**Then** — 結果：「Then the user sees a confirmation message」

## 行動原則

- **原子且可驗證**：單一 session 可完成、具實質意義
- **可追溯鏈**：`Scenario (@tag) → Action (S0XX) → Implementation → Verification`
- **Red-Green-Reflect Loop 就緒**：先 step definitions 再程式碼，永遠先 RED，GREEN 後 REFLECT
- **依賴順序**：Models → services → endpoints，foundation 先於 stories
