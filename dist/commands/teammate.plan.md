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

- `update` → **Update Mode**（保留既有產物、變更前快照、以 `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]` 標記）
- `--ui` → **強制 UI 深度分析**（即使 < 3 個 UI 組件）
- 其他 → **Create Mode**（預設；≥ 3 個 UI 組件自動觸發 UI Deep Analysis）

### 階段 0：基礎檢查

執行 `.teammate/scripts/bash/check-foundation.sh` 並解析 JSON：
- `context` 或 `principles` 非 `complete` → **ERROR**：「請先執行 `/teammate.init`。」
- 兩者皆 `complete` → 載入作為工作脈絡

### 更新模式

以 `update` 執行時：
1. 複製既有 `plan.md`、`scenarios/*.feature` 至 `.teammate/snapshots/`
2. 詢問使用者：「變更內容與原因？」
3. 差異感知處理：比對基準與當前 spec/examples
4. 標記變更：`[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`
5. 同步合約（若存在 `contracts/ui/`）
6. 影響報告 + 不丟棄已完成工作（移除項目改為註解）

---

## 階段 1：場景生成

> 產出：`TASK_DIR/scenarios/*.feature` + `teammate.refs.yaml`

### 設定

1. 執行 `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only`，取得 `TASK_DIR`、`TASK_SPEC`
2. **載入脈絡**：
   - Required：`spec.md`、`example-mapping.md`、`principles.md`
   - Optional：`feature-template.feature`、`contracts/ui/design-principles.md`
3. `mkdir -p TASK_DIR/scenarios`

### UX 衝突掃描（若存在 `design-principles.md`）

在產生 scenarios 前，強制執行衝突分析：
1. 設計原則 vs 核心原則交叉比對（API 可行性、後端 endpoint 需求）
2. 互動元素可行性檢查
3. 參考設計語意差異
4. 有 CONFLICT 或 SEMANTIC_GAP → 使用 `AskQuestion` tool 暫停決策

決策選項：修正設計原則 / 新增後端能力 / 調整語意對齊 / 標記技術債

### 場景生成

依優先序處理每個 User Story：
1. 產生 `.feature` 檔（標頭、Background、已標籤 Scenarios）
2. 對應 Example Mapping：規則 → scenarios，範例 → Given/When/Then
3. 加入 Principles 邊界場景（`@principles @boundary`）
4. 合併資料驅動場景（Scenario Outline）
5. 寫入 `TASK_DIR/scenarios/[story-slug].feature`

### 脈絡錨點

建立/更新 `TASK_DIR/teammate.refs.yaml`（中繼資料、行為參照、依賴）。

### 覆蓋率驗證

每條規則 → ≥1 scenario。每個 P1 story → happy path + negative。每個 principles 邊界 → ≥1 scenario。

### Gherkin 品質檢查

- scenario 獨立可執行、步驟宣告式（WHAT 非 HOW）、不含實作細節
- 標籤慣例：`@P1`/`@P2`/`@P3`、`@happy-path`、`@alternative`、`@negative`、`@boundary`、`@principles`、`@data-driven`

---

## 階段 2：實作計畫 — Part 1：架構

> 產出：`TASK_DIR/plan.md` Part 1（技術架構）

### 載入額外脈絡

Optional：`agent-spec.md`、`docs/llms.txt`、`example-mapping.md`

### 設計資產偵測

- `.teammate/design/figma-index.md` **存在** → UI Deep Analysis 必定觸發 + 啟用 `contracts/ui/ui-spec.md`
- **不存在** → 僅在 `--ui` flag 或 ≥3 UI 組件時觸發

### Compliance Detection

掃描 `context.md` tech stack + codebase：
- **前端**（*.tsx/*.vue/*.svelte 或對應依賴）→ 標記 A11y Compliance（WCAG 2.2 AA），參考 `a11y-compliance/SKILL.md`
- **AI/LLM**（openai/anthropic/langchain 等）→ 標記 AI Risk Compliance（EU AI Act Art. 50），參考 `ai-compliance/SKILL.md`
- codebase 偵測到但 context.md 無標記 → 提示更新 context.md

### 測試基礎設施檢查

掃描既有框架（vitest/jest/pytest 等）。若不存在 → plan.md 新增 Phase 0 setup。若已存在 → 記錄在 Technical Context。

### System Scope Detection

> 產出：plan.md 開頭的 System Scope 表格

掃描檔案/目錄/依賴模式，偵測系統層級：

| Layer | 偵測信號 |
|-------|---------|
| Frontend | `*.tsx`/`*.vue`/`*.svelte`、`src/components/`、react/vue/svelte 依賴 |
| Backend | `*controller.*`/`*service.*`/`*api.*`、`src/api/`、express/fastapi/django 依賴 |
| LLM | openai/anthropic/langchain import、`/chat`/`/completion` routes |
| Database | `*model.*`/`*entity.*`、`src/models/`/`prisma/`、sqlalchemy/prisma/mongoose 依賴 |
| Mobile | `*.swift`/`*.kt`/`*.dart`、`ios/`/`android/`、react-native/flutter 依賴 |

**合規標記**：Frontend → A11y、Backend/Database → Security (OWASP)、LLM → AI Risk、Mobile → Mobile A11y

產出 System Scope 表格（Layer/Status/Evidence/Added）+ Compliance Requirements + Detection Details，插入 plan.md 最開頭。

### 技術規劃

1. **Technical Context**：語言/版本、依賴、儲存、測試框架、約束
2. **Principles Check**：每條原則對應技術決策。*GATE：必須通過*
3. **Actors & Abilities**（選用，≥5 stories）
4. **Project Structure**：檔案標記 `[NEW]`/`[ENHANCE]`/`[INTEGRATE]`

### 整合影響分析

每個 `[NEW]` UI 組件（非子組件）MUST 至少有一個 `[INTEGRATE]` consumer。常見整合點：layout、page、父組件。

### 研究與決策

若有 NEEDS CLARIFICATION → 產生研究任務，彙整於 plan.md Research 區段。

---

## 階段 2.5：UI 深度分析（自動觸發或 --ui）

> 產出：`TASK_DIR/contracts/ui/ui-spec.md`

**觸發條件**（任一）：`figma-index.md` 存在 / UI 組件 ≥ 3 / `--ui` flag。不滿足則跳過。

內容：
1. **組件清單**：類型、狀態數、父組件
2. **屬性與介面**：Props、匯出介面、事件、slot
3. **狀態矩陣**：每個組件 ≥ 3 狀態（預設 + 主要 + 邊界），Loading/Error/Empty MUST 說明內容與使用者動作
4. **互動流程**：核心路徑（happy + error）步驟序列
5. **互動狀態機**：每個元素 MUST 有 enabled + disabled；引用外部設計 MUST 標註語意差異
6. **設計系統合規**：color tokens、spacing、typography、i18n keys、a11y（aria-label、鍵盤導航、對比 ≥ 4.5:1）

全部寫入 `TASK_DIR/contracts/ui/ui-spec.md`。

---

## 階段 3：實作計畫 — Part 2：行動

> 產出：`TASK_DIR/plan.md` Part 2（執行清單）

### 行動格式

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

- `[Type]` **REQUIRED**：`[DESIGN]`/`[LOGIC]`/`[UI]`/`[LOGIC+UI]`
- `[DESIGN]` — 設計稿修改（Pencil / Figma），不涉及程式碼。MUST 排在同 story 的 `[UI]`/`[LOGIC]` actions 之前
- `[LOGIC]` 涉及 util/store/service/model MUST 拆為 RED + GREEN 兩個 actions
- `[UI]` 不強制拆分
- 每個 `[INTEGRATE]` 檔在組件建立 action 後立即產生 mount/import action

### 階段結構

- **Phase: Setup** — 專案初始化、測試基礎設施
- **Phase: Design** — 設計稿修改（Pencil / Figma），需先於程式實作（若任務含設計；無設計則跳過）
- **Phase: Foundational** — 核心基礎設施
- **Phase: User Stories** — 先 step definitions 再實作
- **Phase: Polish** — 橫切關注點

> Phase 依上述順序排列，無設計任務時跳過 Design Phase，編號由 AI 依實際 Phase 數自動分配。

### 追溯矩陣

Scenario Tag → Actions → Status。覆蓋率：[X]/[Y] scenarios ([Z]%)

寫入 `TASK_DIR/plan.md`，使用 `.teammate/templates/plan-template.md`。

---

## 最後步驟

### 更新 Active Context

依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
- **Current State**：Active Task / Phase: Commit (complete) / Last Command: plan / Next Action: /teammate.execute
- **Session Log**：`| [timestamp] | plan | [N] scenarios, plan.md ([N] actions, [coverage]%) | [key decisions] |`

### 完成報告

輸出：產出檔案清單 + 場景摘要 + 計畫摘要（Architecture + Actions）+ 並行機會 → 建議 `/teammate.execute`

## 行動原則

- **原子且可驗證**：單一 session 可完成
- **可追溯鏈**：`Scenario (@tag) → Action (S0XX) → Implementation → Verification`
- **Red-Green-Reflect Loop 就緒**：先 step definitions 再程式碼
- **設計先於程式**：`[DESIGN]` actions 完成後才執行同 story 的 `[UI]`/`[LOGIC]` actions
- **依賴順序**：Models → services → endpoints，foundation 先於 stories
- **步驟宣告式**：Given（脈絡）、When（動作）、Then（結果）
