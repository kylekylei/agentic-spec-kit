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

若使用者輸入非空，**必須**在繼續前納入考量。

## 大綱

觸發訊息中 `/teammate.align` 之後使用者輸入的文字**即為**功能描述。假設對話中始終可取得，即使下方顯示為 `$ARGUMENTS` 字面。除非使用者輸入為空，否則勿要求重複輸入。

基於該功能描述，單次執行 **Impact Mapping + Example Mapping** 工作流程。

### 模式偵測

解析 `$ARGUMENTS` 是否包含關鍵字 **`update`**：

- 若包含 "update" → **Update Mode**（重讀既有 spec、套用變更、保留未變區段）
- 否則 → **Create Mode**（預設）

### 階段 0：基礎檢查

1. **讀取 `.teammate/memory/context.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 模式的佔位符
   - 若發現 → **ERROR**: "Project context not initialized. Run `/teammate.init` first."

2. **讀取 `.teammate/memory/principles.md`**
   - 掃描符合 `[ALL_CAPS_IDENTIFIER]` 模式的佔位符
   - 若發現 → **ERROR**: "Principles not defined. Run `/teammate.init` first."

3. **若兩者皆通過** → 載入兩檔作為工作脈絡：
   - context.md 提供 WHO（角色）、WHY（業務目標）與技術約束
   - principles.md 提供行為邊界與不變條件

4. **Figma URL Detection（動態設計資產建立）**
   - 掃描 `context.md` 中的 Figma URL 模式：`figma.com/design/`、`figma.com/file/`、`figma.com/proto/`
   - **若發現 Figma URL**：
     1. 若不存在則建立 `.teammate/design/` 目錄
     2. 使用模板建立／更新 `.teammate/design/figma-index.md`：
        ```markdown
        # Figma Design Index
        
        > 此檔案由 `/teammate.align` 自動建立，當 `context.md` 包含 Figma URL 時觸發。
        
        ## Project Figma
        
        | 名稱 | URL | 說明 |
        |------|-----|------|
        | [從 context.md 提取的名稱或 "Main Design"] | [URL] | 專案主設計檔 |
        
        ## Feature Pages
        
        <!-- /teammate.plan 執行時會在此追加 feature-specific 頁面連結 -->
        
        | Feature | Page URL | 狀態 |
        |---------|----------|------|
        ```
     3. Log: "Figma URL detected → `.teammate/design/figma-index.md` created"
   - **若無 Figma URL** → 略過（不建立設計資產）

### 階段 1：設定

1. **產生簡短分支名稱**（2–4 字）：
   - 分析功能描述並萃取最有意義的關鍵字
   - 盡可能使用動作-名詞格式（如 "add-user-auth"、"fix-payment-bug"）
   - 保留技術術語與縮寫

2. **建立新分支前先檢查既有分支**：

   a. 取得所有遠端分支：
      ```bash
      git fetch --all --prune
      ```

   b. 找出該 short-name 在各來源中的最高功能編號：
      - 遠端分支：`git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - 本地分支：`git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - 任務目錄：檢查 `tasks/[0-9]+-<short-name>` 模式

   c. 新分支編號使用 N+1。

   d. 以計算出的編號與 short-name 執行 `.teammate/scripts/bash/create-new-task.sh --json "$ARGUMENTS"`。
      - 參數含單引號時使用跳脫語法：如 'I'\''m Groot'

### 階段 2：Impact Mapping

執行 Impact Mapping 框架以推導有價值的行為：

#### WHO (Actors)

1. **識別所有與此功能互動的角色**：
   - 主要使用者（直接受益者）
   - 次要使用者（使用產出者）
   - 系統角色（外部系統、AI 代理）
   - 管理角色（管理／設定者）

2. 為每位角色定義：角色名稱、主要目標、當前痛點

#### WHY (Business Goals)

3. **定義此功能應創造的業務影響**：
   - 能促成什麼業務成果？
   - 如何衡量成功？
   - 若不建構會如何？

4. 將每位角色連結至業務目標。

#### HOW (Capabilities)

5. **識別達成目標所需的能耐**。

#### WHAT (Features/Behaviors)

6. **從能耐推導具體行為**：
   - 每項行為須可觀察、可測試，且能獨立交付價值

### 階段 3：規格撰寫

1. 載入 `.teammate/templates/spec-template.md` 以了解必要區段。

2. **填寫規格**：
   - 從 Input 解析使用者描述（若為空：ERROR）
   - 將 Impact Mapping 結果對應至 User Stories
   - 不明確處：依脈絡做合理推測
     - 僅在選擇顯著影響範疇時標記 [NEEDS CLARIFICATION: 具體問題]
     - **限制：最多 3 個 [NEEDS CLARIFICATION] 標記**
   - 填寫 User Scenarios & Testing 區段（依業務價值排序）
   - 產生 Functional Requirements（每項須可測試）
   - 定義 Success Criteria（可衡量、技術無關）
   - 識別 Key Entities（若有資料）

3. 將規格寫入 `TASK_DIR/spec.md`。

### 階段 4：規格驗證

1. **建立規格品質檢查表**：產生 `TASK_DIR/checklists/requirements.md`

2. **依下列準則驗證**：
   - 無實作細節（語言、框架、API）
   - 聚焦使用者價值與業務需求
   - 以非技術利害關係人為對象撰寫
   - 需求可測試且無歧義
   - 成功標準可衡量且技術無關

3. **處理驗證結果**：
   - 全部通過：進入階段 5
   - 有項目未通過：更新 spec（最多 3 次迭代）
   - 若仍有 [NEEDS CLARIFICATION] 標記：向使用者呈現選項

### 階段 5：Example Mapping

將抽象 User Stories 轉為具體、可測試的範例，為 Gherkin 場景奠定基礎。

> 此階段整合了原 `/teammate.clarify` 的功能。不足時補最多 3 問，不中斷流程。

1. **針對每個 User Story**（依優先序 P1、P2、P3...）：

   #### 步驟 1：Story Card
   - 以 As a / I want / So that 格式萃取 user story
   - 確認業務價值

   #### 步驟 2：Rules Discovery
   - 識別**業務規則**：
     - 須滿足哪些條件？有哪些約束？
     - 允許哪些變體？不允許什麼？（principles 邊界）
   - 每條規則：撰寫清晰、可測試的陳述；對照 principles 檢查衝突

   #### 步驟 3：Examples Generation
   - 為每條規則產生**具體範例**：
     - 至少一個 **happy path** 範例
     - 至少一個 **alternative** 範例（若適用）
     - 至少一個 **negative/error** 範例
     - 考量 **boundary conditions**
   - 每個範例遵循 Given/When/Then 格式

   #### 步驟 4：Questions Collection
   - 記錄產生的**問題**（模糊需求、缺漏資訊、邊界情況、principles 衝突）
   - 每個問題：清楚陳述、評估影響（High/Medium/Low）、標記 Open 或 Resolved
   - **Inline Resolution**：若有 High impact 問題，直接在此步驟中提出（最多 3 個），附帶建議選項讓使用者選擇。不中斷流程。

2. **Principles Boundary Check**：對每條規則與範例對照 principles 驗證，並加入明確邊界範例。

3. **產生 Example Mapping 文件**：使用 `.teammate/templates/example-mapping-template.md` 寫入 `TASK_DIR/example-mapping.md`

4. **就緒評估**：

   | 指標 | 當前 | 目標 | 狀態 |
   |------|------|------|------|
   | Rules per story | [N] | 3+ | [Pass/Fail] |
   | Examples per rule | [Avg] | 2+ | [Pass/Fail] |
   | Open questions | [N] | 0 high-impact | [Pass/Fail] |
   | Principles boundaries | [N] | 1+ per story | [Pass/Fail] |

### 階段 6：Downstream Impact Check（僅 Update Mode）

若為 Update Mode 且 `TASK_DIR/plan.md` 已存在：

1. **比對 spec.md 修改內容與 plan.md**：
   - 新增/移除的 User Story → plan.md 的 scenarios + actions 需更新
   - 需求變更（FR 修改、Success Criteria 變更） → Architecture decisions 可能需調整
   - Example Mapping 新增 rules/examples → scenarios 可能需新增

2. **產出影響摘要**：
   ```
   ## Downstream Impact
   
   plan.md 狀態：[OUTDATED / UP-TO-DATE]
   
   受影響區域：
   - [N] User Stories 新增/修改 → scenarios 需更新
   - [N] FR 變更 → Architecture 可能需調整
   - [N] 新 rules → 可能需新增 scenarios
   
   建議：執行 `/teammate.plan update` 同步更新
   ```

3. **判斷規則**：
   - 有結構性變更（新增/移除 story、FR 修改） → 標記 `OUTDATED`，強烈建議 plan update
   - 僅 wording 修正（無結構變更） → 標記 `UP-TO-DATE`，plan.md 無需更新

> Create Mode 時跳過此步驟（plan.md 尚不存在）。

### 階段 7：更新進度脈絡（Memory Delta Protocol）

以 delta 模式更新 `.teammate/memory/progress.md`：
- **覆寫 `## Current State`**：Active Task: [name], Branch: [branch], Phase: Align (complete), Last Command: align, Next Action: /teammate.plan
- **追加 `## Session Log`**：`| [timestamp] | align | Task: [name], spec.md + example-mapping.md | [rules/examples count, open questions] |`
- **更新 `## Blockers`**：如有未解決的 high-impact questions，記錄為 blocker

### 階段 8：完成報告

輸出：
- 分支名稱
- Spec 檔案路徑 + Example Mapping 檔案路徑
- Impact Mapping 摘要（Actors → Goals → Capabilities → Behaviors）
- Example Mapping 摘要（Stories → Rules → Examples → Questions）
- `/teammate.plan` 就緒狀態
- 建議下一步指令：`/teammate.plan`

## 快速指引

- 聚焦 **WHO** 要 **WHAT** 以及 **WHY**。
- 避免 HOW 實作（不提技術棧、API、程式結構）。
- 以業務利害關係人為對象，非開發者。
- 每項行為須可觀察且可測試。
- 將每項功能連結至業務目標。

### 成功標準指引

成功標準須：
1. **可衡量**：含具體指標（時間、百分比、數量、比率）
2. **技術無關**：不提框架、語言、資料庫或工具
3. **使用者導向**：從使用者／業務視角描述成果
4. **可驗證**：無需知道實作細節即可測試／驗證

### 範例映射最佳實踐

**良好規則**："Users must be authenticated to access protected resources"、"Orders cannot be modified after shipping"

**不良規則**："The system should be secure"（太模糊）、"It must be fast"（無門檻）

**Principles Boundaries**：每個 story 須明確加入系統 MUST NOT 的範例。

## 行為規則

- Update Mode 下若 spec 已存在，保留未變區段
- 每 session 內嵌問題不超過 3 個
- 尊重使用者提早結束訊號（"stop"、"done"、"proceed"）
- 始終產出 spec.md 與 example-mapping.md（若有問題標記為 draft）
- P1 stories 優先加入 principles 邊界範例
