---
description: 透過 Impact Mapping 定義要建構的內容，並以 Example Mapping 釐清需求。單次產出 spec.md + example-mapping.md。
handoffs: 
  - label: 建立工作計畫
    agent: teammate.plan
    prompt: 產生 Gherkin 場景、技術計畫與行動清單
    send: true
  - label: 繼續編輯規格
    agent: teammate.align
    prompt: 繼續精修當前規格
  - label: 跳過至執行
    agent: teammate.execute
    prompt: 開始實作 — 規格已足夠，無需進一步規劃
    send: true
---

## 使用者輸入

```text
$ARGUMENTS
```

若使用者輸入非空，**必須**在繼續前納入考量。`/teammate.align` 之後的文字**即為**功能描述，勿要求重複輸入。

## 大綱

基於功能描述，單次執行 **Impact Mapping + Example Mapping** 工作流程。

### 模式偵測

- `$ARGUMENTS` 包含 `update` → **Update Mode**（重讀既有 spec、保留未變區段）
- `$ARGUMENTS` 包含 Pencil node IDs（`/` 分隔路徑）、`.pen` 檔案路徑，或「設計稿」、「優化」、「UI 調整」等關鍵字 → **Design Mode**（見下方）
- 否則 → **Create Mode**

### Design Mode（設計任務分流）

當偵測為設計任務時，流程調整如下：

**適用情境**：Pencil `.pen` 設計稿修改、Figma 設計稿優化、純視覺/UX 調整。

**執行順序**：
1. 階段 0–1（基礎檢查 + 設定）照常執行
2. 階段 2（Impact Mapping）簡化為 **Design Intent Mapping**：
   - WHO：受影響的使用者角色
   - WHY：設計改善的目標（UX 問題、視覺一致性、可用性提升）
   - WHAT：具體的設計變更項目（可觀察、可驗證）
3. 階段 3（規格撰寫）產出 `contracts/ui/ui-spec.md`（替代或補充 `spec.md`），內容包含：
   - 設計意圖與問題描述
   - 變更項目清單（node/component 對應）
   - 視覺驗證標準（可截圖比對）
4. 階段 4–5（驗證 + Example Mapping）可選 — 純視覺調整可省略；涉及互動行為變更時仍須執行
5. 設計稿修改允許先於 `spec.md`（`.pen` / Figma 變更視同設計文件更新）
6. 階段 6–8 照常執行

**產物對照**：

| 標準流程產物 | Design Mode 產物 |
|-------------|-----------------|
| `spec.md` | `contracts/ui/ui-spec.md`（必須）+ `spec.md`（僅行為變更時） |
| `example-mapping.md` | 可選（僅互動行為變更時） |

**回歸標準流程條件**：設計修改涉及新增使用者行為、Principles 邊界變更、或跨模組影響。

### 階段 0：基礎檢查

執行 `.teammate/scripts/bash/check-foundation.sh` 並解析 JSON：
- `context` 或 `principles` 非 `complete` → **ERROR**: "Run `/teammate.init` first."
- 兩者皆 `complete` → 載入 `context.md`（WHO/WHY/技術約束）與 `principles.md`（行為邊界）

**Figma URL Detection**：掃描 `context.md` 中的 Figma URL（`figma.com/design/`、`/file/`、`/proto/`）。若發現 → 建立 `.teammate/design/figma-index.md`（Project Figma 表 + 空的 Feature Pages 表）。若無 → 略過。

### 階段 1：設定

1. **產生分支名稱**（2–4 字，動作-名詞格式，如 `add-user-auth`）

2. **檢查既有分支編號**：
   - 掃描遠端（`git fetch --all --prune` + `git ls-remote`）、本地分支、`tasks/` 目錄
   - 新分支使用 N+1 編號
   - 執行 `.teammate/scripts/bash/create-new-task.sh --json "$ARGUMENTS"`
   - 參數含單引號時使用 escape 語法：`'I'\''m Groot'`

### 階段 2：Impact Mapping

推導有價值的行為：

1. **WHO (Actors)**：識別所有角色（主要使用者、次要使用者、系統角色、管理角色），定義名稱、目標、痛點
2. **WHY (Business Goals)**：定義業務影響、衡量方式、不建構的後果，連結角色至目標
3. **HOW (Capabilities)**：識別達成目標所需的能耐
4. **WHAT (Features/Behaviors)**：從能耐推導具體行為 — 每項須可觀察、可測試、可獨立交付

### 階段 3：規格撰寫

1. 載入 `.teammate/templates/spec-template.md`
2. 填寫規格：
   - 將 Impact Mapping 結果對應至 User Stories
   - 不明確處依脈絡推測，僅在顯著影響範疇時標記 `[NEEDS CLARIFICATION]`（**最多 3 個**）
   - 產生 Functional Requirements（可測試）、Success Criteria（可衡量、技術無關）、Key Entities
3. 寫入 `TASK_DIR/spec.md`

### 階段 4：規格驗證

1. 產生 `TASK_DIR/checklists/requirements.md`
2. 驗證準則：無實作細節、聚焦使用者價值、以非技術利害關係人為對象、需求可測試無歧義、成功標準可衡量
3. 未通過 → 更新 spec（最多 3 次迭代）；仍有 `[NEEDS CLARIFICATION]` → 向使用者呈現選項

### 階段 5：Example Mapping

將 User Stories 轉為具體、可測試範例，為 Gherkin 場景奠定基礎。不足時補最多 3 問，不中斷流程。

針對每個 User Story（依 P1→P2→P3 優先序）：

1. **Story Card**：As a / I want / So that 格式，確認業務價值
2. **Rules Discovery**：識別業務規則（條件、約束、允許變體、principles 邊界），每條清晰可測試
3. **Examples Generation**：每條規則至少產生 happy path + alternative（若適用）+ negative 範例 + boundary conditions，遵循 Given/When/Then
4. **Questions Collection**：記錄模糊處（影響 High/Medium/Low），High impact 問題直接提出（最多 3 個）附建議選項

完成後：
- **Principles Boundary Check**：對照 principles 驗證，加入邊界範例
- 使用模板寫入 `TASK_DIR/example-mapping.md`
- **就緒評估**：Rules ≥ 3/story、Examples ≥ 2/rule、Open questions 0 high-impact、Principles boundaries ≥ 1/story

### 階段 6：Downstream Impact Check（僅 Update Mode）

若 `TASK_DIR/plan.md` 已存在：
- 比對 spec.md 修改 vs plan.md（新增/移除 Story → scenarios 需更新、FR 變更 → Architecture 可能需調整、新 rules → 可能需新 scenarios）
- 有結構性變更 → 標記 `OUTDATED`，建議 `/teammate.plan update`
- 僅 wording 修正 → 標記 `UP-TO-DATE`

### 階段 7：更新 Active Context

依 **Memory Delta Protocol**（見 `teammate-rules.mdc`）更新 `progress.md`：
- **Current State**：Active Task / Branch / Phase: Align (complete) / Last Command: align / Next Action: /teammate.plan
- **Session Log**：`| [timestamp] | align | Task: [name], spec.md + example-mapping.md | [rules/examples count, open questions] |`
- **Blockers**：未解決的 high-impact questions

### 階段 8：完成報告

輸出：分支名稱 + 檔案路徑 + Impact Mapping 摘要 + Example Mapping 摘要 + 就緒狀態 → 建議 `/teammate.plan`

## 行為規則

- 聚焦 **WHO/WHAT/WHY**，避免 HOW 實作（不提技術棧、API、程式結構）
- 每項行為須可觀察且可測試，連結至業務目標
- 成功標準：可衡量（具體指標）、技術無關、使用者導向、可驗證
- Update Mode 保留未變區段
- 每 session 內嵌問題不超過 3 個
- 尊重使用者提早結束訊號（"stop"、"done"、"proceed"）
- 始終產出 spec.md + example-mapping.md（有問題標記為 draft）
- P1 stories 優先加入 principles 邊界範例
