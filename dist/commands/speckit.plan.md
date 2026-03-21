---
description: 實作視圖——產出 Gherkin 情境與 plan.md（架構 + Actions）。
handoffs: 
  - label: 執行行動
    agent: speckit.execute
    prompt: 啟動 Red-Green Loop 實作
    send: true
  - label: 審查覆蓋率
    agent: speckit.review
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

執行 `skills/speckit/scripts/bash/check-foundation.sh`並解析 JSON：
- `context` 或 `principles` 非 `complete` → **ERROR**：「請先執行 `/speckit.init`。」
- 兩者皆 `complete` → 載入作為工作脈絡

### 更新模式

以 `update` 執行時：
1. 複製既有 `plan.md`、`scenarios/*.feature` 至 `.specify/snapshots/`
2. 詢問使用者：「變更內容與原因？」
3. 差異感知處理：比對基準與當前 spec/examples
4. 標記變更：`[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`
5. 同步合約（若存在 `contracts/ui/`）
6. 影響報告 + 不丟棄已完成工作（移除項目改為註解）

---

## 階段 1：場景生成

> 產出：`SPEC_DIR/scenarios/*.feature` + `speckit.refs.yaml`

### 設定

1. 執行 `skills/speckit/scripts/bash/check-prerequisites.sh --json --paths-only`，取得 `SPEC_DIR`、`SPEC_PATH`
2. **載入脈絡**：
   - Required：`spec.md`、`example-mapping.md`、`principles.md`
   - Optional：`feature-template.feature`、`contracts/ui/design-principles.md`
3. `mkdir -p SPEC_DIR/scenarios`

### UX 衝突掃描（若存在 `design-principles.md`）

在產生 scenarios 前，若 `contracts/ui/design-principles.md` 存在，執行交叉比對：

| 發現 | 行為 |
|------|------|
| 設計原則 vs 核心原則無衝突 | 繼續生成 scenarios |
| 發現 `CONFLICT`（API 可行性、後端 endpoint、互動元素）| 用 `AskQuestion` 暫停，提供：修正設計原則 / 新增後端能力 / 調整語意對齊 / 標記技術債 |
| 發現 `SEMANTIC_GAP`（參考設計語意差異）| 同上 |

### 場景生成

依優先序處理每個 User Story：
1. 產生 `.feature` 檔（標頭、Background、已標籤 Scenarios）
2. 對應 Example Mapping：規則 → scenarios，範例 → Given/When/Then
3. 加入 Principles 邊界場景（`@principles @boundary`）
4. 合併資料驅動場景（Scenario Outline）
5. 寫入 `SPEC_DIR/scenarios/[story-slug].feature`

### 脈絡錨點

建立/更新 `SPEC_DIR/speckit.refs.yaml`（中繼資料、行為參照、依賴）。

### 覆蓋率驗證

每條規則 → ≥1 scenario。每個 P1 story → happy path + negative。每個 principles 邊界 → ≥1 scenario。

### Gherkin 品質檢查

- scenario 獨立可執行、步驟宣告式（WHAT 非 HOW）、不含實作細節
- 標籤慣例：`@P1`/`@P2`/`@P3`、`@happy-path`、`@alternative`、`@negative`、`@boundary`、`@principles`、`@data-driven`

---

## 階段 2：實作計畫 — Part 1：架構

> 產出：`SPEC_DIR/plan.md` Part 1（技術架構）

### 載入額外脈絡

條件必載（存在即載入）：最近 2 個已完成任務的 `insights.md`（架構決策與踩坑經驗影響規劃品質）

Optional：`agent-spec.md`、`docs/llms.txt`、`example-mapping.md`

### 設計資產偵測

- `.specify/design/figma-index.md` **存在** → UI Deep Analysis 必定觸發 + 啟用 `contracts/ui/ui-spec.md`
- **不存在** → 僅在 `--ui` flag 或 ≥3 UI 組件時觸發

### Compliance Detection 與 System Scope Detection

執行 `skills/speckit/scripts/bash/detect-system-scope.sh --json` 並解析輸出：
- `layers`：各系統層是否啟用（frontend / backend / llm / database / mobile）
- `compliance`：對應合規需求（a11y / security-owasp / ai-risk / mobile-a11y）
- `missing_context`：若有標記 → 提示更新 `context.md`

依 `layers` 結果建立 **System Scope 表格**（Layer/Status/Evidence/Added），插入 `plan.md` 最開頭。

### 技術規劃

1. **Technical Context**：語言/版本、依賴、儲存、測試框架、約束
2. **Principles Check**：每條原則對應技術決策。*GATE：必須通過*
3. **Actors & Abilities**（選用，≥5 stories）
4. **Project Structure**：檔案標記 `[NEW]`/`[ENHANCE]`/`[INTEGRATE]`
5. **型別定義產出物**（新增，依需要擇一）：
   - `types.d.ts`（前端 / Node）
   - `schema.sql`（DB）
   - 對應 Interface / Protobuf 定義

   > 根據 `spec.md` 的 Key Entities 與 Success Criteria 直接生成邊界明確的型別，列入 Architecture 產出物清單。

### 整合影響分析

每個 `[NEW]` UI 組件（非子組件）MUST 至少有一個 `[INTEGRATE]` consumer。常見整合點：layout、page、父組件。

### 研究與決策

若有 NEEDS CLARIFICATION → 產生研究任務，彙整於 plan.md Research 區段。

---

## 階段 2.5：UI 深度分析（自動觸發或 --ui）

> 產出：`SPEC_DIR/contracts/ui/ui-spec.md`

**觸發條件**（任一）：`figma-index.md` 存在 / UI 組件 ≥ 3 / `--ui` flag。不滿足則跳過。

依 `skills/speckit/references/ui-spec-format.md` 的格式規範撰寫，涵蓋：組件清單、屬性介面、狀態矩陣（≥3 狀態）、互動流程、互動狀態機、設計系統合規（tokens / i18n / a11y）。

全部寫入 `SPEC_DIR/contracts/ui/ui-spec.md`。

---

## 階段 3：實作計畫 — Part 2：行動

> 產出：`SPEC_DIR/plan.md` Part 2（執行清單）

### 行動格式

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

- `[Type]` **REQUIRED**：`[DESIGN]`/`[LOGIC]`/`[UI]`/`[LOGIC+UI]`
- `[DESIGN]` — 設計稿修改（Pencil / Figma），不涉及程式碼。MUST 排在同 story 的 `[UI]`/`[LOGIC]` actions 之前
- `[LOGIC]` 涉及 util/store/service/model MUST 拆為 RED + GREEN 兩個 actions
- `[UI]` 不強制拆分
- 每個 `[INTEGRATE]` 檔在組件建立 action 後立即產生 mount/import action
- **每條 Action Description 控制在單行**：描述聚焦「做什麼」，不包含實作細節或展開說明。

### 階段結構

- **Phase: Setup** — 專案初始化、測試基礎設施
- **Phase: Design** — 設計稿修改（Pencil / Figma），需先於程式實作（若任務含設計；無設計則跳過）
- **Phase: Foundational** — 核心基礎設施
- **Phase: User Stories** — 先 step definitions 再實作
- **Phase: Polish** — 橫切關注點

> Phase 依上述順序排列，無設計任務時跳過 Design Phase，編號由 AI 依實際 Phase 數自動分配。

### 追溯矩陣

Scenario Tag → Actions → Status。覆蓋率：[X]/[Y] scenarios ([Z]%)

寫入 `SPEC_DIR/plan.md`，使用 `.specify/templates/plan-template.md`。

---

## 最後步驟

### 更新 Active Context

依 **Memory Delta Protocol**（見 `speckit-rules.mdc`）更新 `progress.md`：
- **Current State**：Active Task / Phase: Commit (complete) / Last Command: plan / Next Action: /speckit.execute
- **Session Log**：`| [timestamp] | plan | [N] scenarios, plan.md ([N] actions, [coverage]%) | [key decisions] |`

### 完成報告

輸出：產出檔案清單 + 場景摘要 + 計畫摘要（Architecture + Actions）+ 並行機會 → 建議 `/speckit.execute`

## 行動原則

- **原子且可驗證**：單一 session 可完成
- **可追溯鏈**：`Scenario (@tag) → Action (S0XX) → Implementation → Verification`
- **Red-Green-Reflect Loop 就緒**：先 step definitions 再程式碼
- **設計先於程式**：`[DESIGN]` actions 完成後才執行同 story 的 `[UI]`/`[LOGIC]` actions
- **依賴順序**：Models → services → endpoints，foundation 先於 stories
- **步驟宣告式**：Given（脈絡）、When（動作）、Then（結果）
