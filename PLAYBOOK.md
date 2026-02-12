# Teammate Playbook

> 框架演進紀錄：計劃、變更、跨專案教訓

---

## 已完成

### Simplified Flow 規則 (2026-02-08)

**來源**: oReady Feature 003 實作時發現 AI 跳過規劃直接動手

**改善**: 在 `teammate-rules.mdc` 新增 Simplified Flow 區段，定義：
- 簡化條件（單一模組、非行為變更、< 2 小時、不涉及 Principles）
- 最低要求（spec.md + tasks.md 必須存在）
- AI 必須明確告知使用者並等待確認

**狀態**: 已同步到 oReady 和 Teammate

### Handoffs 擴充 (2026-02-08)

**來源**: `/teammate.align update` 完成後缺少合理的下一步選項

**改善**: `teammate.align.md` 新增 3 個 handoffs：
- Update Tasks — 跳到 `/teammate.tasks update`
- Continue Editing Spec — 繼續修改 spec
- Skip to Execute — 簡化流程直接執行

**狀態**: 已同步到 oReady 和 Teammate

---

## 計劃中

### P1: install.sh 安裝腳本 (暫時不執行)

**動機**: 讓 Teammate 可以一鍵安裝到任何專案，取代手動複製和 sync rule

**設計**:

```bash
# 在任何專案中安裝 Teammate
~/Developer/Teammate/install.sh

# 或指定路徑
~/Developer/Teammate/install.sh --target /path/to/project
```

**安裝內容** (複製到目標專案):
- `.teammate/templates/` — 文件模板
- `.teammate/scripts/` — 自動化腳本
- `.teammate/config/` — 設定檔
- `.cursor/commands/teammate.*.md` — Cursor 指令
- `.cursor/rules/teammate-rules.mdc` — AI 工作規範

**不覆蓋** (專案私有):
- `.teammate/memory/` — 專案上下文、原則、進度
- `.teammate/snapshots/` — 快照
- `features/` — Feature 工作目錄
- `.cursor/rules/` 中非 teammate 的規則

**更新模式**:
```bash
~/Developer/Teammate/install.sh --update  # 只更新框架檔案，不動專案內容
```

**驗收標準**:
- 新專案安裝後可立即執行 `/teammate.kickoff`
- 已有專案更新後不影響既有 memory 和 features
- 安裝後自動印出版本和可用指令清單

---

### P2: 版本管理 ✅

**動機**: 不同專案可能需要不同版本的 Teammate

**已完成（2026-02-11）**:
- `teammate.yml` 新增 `version: "0.0.1"` 正式欄位（從 `# Version: 2.0.0` 註解升級）
- 新建 `CHANGELOG.md`，以 `[0.0.1]` 作為 baseline + `[Unreleased]` 區段
- `teammate.toolkit.md` 實作 `migrate` 工具（8 步驟：Locate Hub → Compare → Parse Changelog → Diff → Report → Confirm → Apply → Update Context）
- `teammatesync_rule.mdc` 新增 Version Tracking sync 規則 + `.cursorule` 不同步
- `teammate-rules.mdc` Key Paths 新增 `CHANGELOG.md`
- 版本語意：0.x.y 快速迭代（未公開），1.0.0 起遵循 semver

**未來延伸**（與 P1 整合時）:
- `install.sh` 支援 `--version v1.2.0`
- Git tag 標記每個穩定版本

---

### P3: 多專案同步機制

**動機**: 在 oReady 實戰中用 `teammatesync_rule.mdc` 讓 AI 同步兩個 repo，但這依賴 AI 記得

**方案評估**:

| 方案 | 即時同步 | 複雜度 | 適合場景 |
|------|---------|--------|---------|
| Sync Rule (目前) | 靠 AI | 低 | 1-2 個專案，單人 |
| Symlink | 即時 | 中 | 單機多專案，不需 git 追蹤 |
| install.sh (P1) | 手動 | 低 | 正式發佈，多人 |
| Git Submodule | 手動 | 高 | 多人協作，版本嚴格控制 |

**建議路線**: Sync Rule → install.sh → Submodule（依使用規模遞進）

---

### P4: 指令合成（Command Consolidation）✅

**動機**: Phase A 實戰後發現 PM/設計端無法消化 11 個指令的工程流程，需要語意化精簡

**已完成（2026-02-11）**:

| 合併前 | 合併後 | 產出 |
|--------|--------|------|
| `align` + `clarify` | `/teammate.align` | `spec.md` + `example-mapping.md`（不足補最多 3 問，不中斷） |
| `plan` + `tasks` + `actions` | `/teammate.plan` | `.feature` + `tasks.md` + `actions.md` |
| `review` + `checklist` | `/teammate.review` | 行為覆蓋分析 + 交付檢核清單（合併為同一份） |

**唯一新增**: `/teammate.ui`
- UI 元件與畫面狀態需求（Loading / Empty / Error）
- 互動流程（核心 paths）
- UI / i18n / a11y / 設計系統檢核清單
- 對應 spec / tasks 簡表

**精簡後流程**（PM 只需記住）：

```
Foundation: kickoff → principles（一次性）
Per Feature: align → plan → execute → review
UI-Only:    ui → execute → review
```

**已刪除的指令**：
- `teammate.clarify.md` → 併入 `align`
- `teammate.tasks.md` → 併入 `plan`
- `teammate.actions.md` → 併入 `plan`
- `teammate.checklist.md` → 併入 `review`

**配套更新**：`teammate-rules.mdc` 指令表、Key Paths、Mid-Cycle Updates；`teammate.yml` lifecycle；所有指令的交叉引用

---

### P5: ACE 產品開發知識閉環（Agentic Context Engineering）✅

**動機**: 對照 ACE 框架與 Agentic Engineering 原則發現，Teammate 的產品開發流程在知識累積、增量更新、上下文深度、風險管控、可觀測性等面向有結構性缺口。AI 在 execute 過程中發現的 codebase 慣例、陷阱、技術決策，無法結構化持久保存並在後續 actions/features 中復用，且 memory 檔案的全量覆寫模式有 Context Collapse 風險。

**核心問題**:

| 問題 | 來源原則 | 說明 |
|------|---------|------|
| Execute 無反思步驟 | ACE: Grow-and-Refine | Red-Green Loop 完成後直接跳到下一個 action，不記錄學到的 codebase 知識 |
| 跨 Feature 知識不傳遞 | ACE: Dynamic Cheatsheet | execute 只載入當前 feature 的 artifacts，Feature 002 無法受益於 Feature 001 的執行經驗 |
| Memory 全量覆寫 | ACE: Incremental Delta | `active-context.md` 每個指令都做全量覆寫，經 10+ 次重寫後早期細節流失（Context Collapse） |
| 關鍵資源被列為 Optional | ACE: Combat Brevity Bias | `docs/llms.txt`、`contracts/`、`screenplay.md` 為 Optional，AI 常跳過導致用錯 API pattern |
| Execute 缺乏風險暫停 | Agentic: HITL | 只有「失敗時暫停」，缺少「高風險操作前暫停」（如修改 Principles 邊界程式碼） |
| 無決策軌跡 | Agentic: Observability | AI 的選擇與推理路徑沒有結構化記錄，事後難以回溯是 context 不足還是邏輯錯誤 |

**ACE + Agentic 原則對應設計**:

| 原則 | Teammate 對應設計 | 產品開發範例 |
|------|-----------------|-------------|
| Dynamic Cheatsheet（動態備忘錄） | `features/[###-name]/insights.md` | 「這專案用 `$derived` 不用 `$:`」 |
| Reflector（反思器） | execute Red-Green Loop 新增 REFLECT 步驟 | 每個 action GREEN 後快速自檢 |
| Curator（策展器） | Insights Graduation 機制 | 重複 3+ 次的 insight 提升為 project-context/principles |
| Incremental Delta（增量更新） | Memory Delta Protocol | `active-context.md` 改為 append section，不再全量覆寫 |
| Combat Brevity Bias（反簡短偏差） | Context Loading Discipline | `docs/` 和 `contracts/` 升級為條件性必載 |
| HITL（人機協同） | Risk-Based Gates | Principles 邊界操作前自動暫停詢問用戶 |
| Observability（可觀測性） | Decision Trace | 在 insights.md 新增 Decision Log section |

---

**改善 A: Feature-Level Insights（動態備忘錄）**

每個 feature 新增 `insights.md`，結構化記錄五類產品知識：

```
features/[###-feature-name]/
  └── insights.md          <-- 新增
```

```markdown
# Feature Insights

## Codebase Conventions（慣例）
- [S003] Svelte reactive 一律使用 `$derived`，不用 `$:` IIFE

## Gotchas（陷阱）
- [S004] locale JSON 新增 key 時 en-US 和 zh-TW 必須同步

## Technical Decisions（技術決策）
- [S002] 選擇 EventSource 而非 WebSocket，因為只需單向推送

## Patterns Discovered（發現的模式）
- [S001] 兄弟組件統一使用 `onMount` + `loadData` pattern

## Decision Log（決策軌跡）
- [S006] 遇到分頁 API 設計選擇：offset vs cursor-based → 選擇 cursor-based，因為資料量持續增長且 offset 在資料變動時會跳頁
- [S009] TabPanel 可複用既有 `Tabs.svelte` 或新建 → 選擇複用，因為 insights 記錄兄弟組件統一使用相同 pattern
```

> Decision Log 與 Technical Decisions 的差異：Technical Decisions 記錄「最終結論」，Decision Log 記錄「選擇過程與替代方案」，供事後回溯 AI 的推理路徑。

---

**改善 B: Execute Reflect Step（反思器）**

修改 `teammate.execute.md` 的 Red-Green Loop：

```
現在: RED → GREEN → REFACTOR → REPEAT
改為: RED → GREEN → REFACTOR → REFLECT → REPEAT
```

REFLECT 規則：
- 耗時不超過 30 秒的快速自檢
- 五個固定問題：
  1. 發現了 codebase 慣例或 pattern？
  2. 踩到了陷阱或需要注意的事項？
  3. 做了需要記錄的技術決策？
  4. 做了涉及替代方案取捨的選擇？（→ Decision Log）
  5. 先前 insight 需修正？
- 有新發現才寫入 `insights.md`，無則跳過（避免噪音）
- 寫入時標記 Action ID（如 `[S003]`）保留可追溯性

---

**改善 C: Smart Context Loading（知識注入 + 反簡短偏差）**

修改 `teammate.execute.md` Step 3 "Load Implementation Context"，重新定義載入層級：

```markdown
Required（必載）:
  - actions.md
  - tasks.md
  - scenarios/*.feature

Recommended（條件必載 — 存在即載入，不得跳過）:
  - FEATURE_DIR/insights.md（當前 feature 的動態備忘錄）
  - 最近 2 個已完成 feature 的 insights.md（跨 feature 知識傳遞）
  - docs/llms.txt → 比對 tasks.md 的 dependencies，自動載入對應的 docs/[library]/llms.txt
  - contracts/（API / UI / AI contracts，如目錄存在）
  - screenplay.md（如存在）

Optional（輔助參考）:
  - data-model.md
  - research.md
```

> 關鍵變更：`docs/llms.txt`、`contracts/`、`screenplay.md` 從 Optional 升級為 Recommended。AI 不得以「簡短偏差」為由跳過這些資源。只取最近 2 個 insights 的理由：避免 context window 過載；足夠重要的 insight 應「畢業」到 project-context。

---

**改善 D: Insights Graduation（知識畢業）**

當某個 insight 在 3+ 個 features 重複出現，AI 在 REFLECT 中應建議：
- 慣例/模式 → 提升到 `project-context.md` 的 Architecture Patterns
- 陷阱/約束 → 提升到 `principles.md` 的新 MUST/MUST NOT 規則

---

**改善 E: Memory Delta Protocol（增量更新，防 Context Collapse）**

**問題**：目前每個指令對 `active-context.md` 做全量覆寫（「Mark X as complete → Set next action」）。經過一個 feature 生命週期的 10+ 次覆寫，早期記錄的細節（如 kickoff 時的 bootstrap 狀態、align 時的 key decisions）會被 LLM 逐步簡化或丟失。

**解法**：將 `active-context.md` 改為**分區追加模式**，而非全量覆寫：

```markdown
# Active Context

## Current State
<!-- 此區塊由最近一個指令覆寫 -->
- Phase: Deliver
- Last Command: execute S008
- Next Action: execute S009 (next) 或 review

## Session Log
<!-- 此區塊為 append-only，每個指令完成時追加一行，不修改既有內容 -->
| Timestamp | Command | Key Output | Notes |
|-----------|---------|------------|-------|
| 02-10 09:15 | kickoff | Bootstrap OK, Python 3.12 | — |
| 02-10 09:30 | principles | 12 MUST, 5 MUST NOT | — |
| 02-10 10:00 | align | Feature: 003-sse-streaming, Branch created | 3 NEEDS CLARIFICATION |
| 02-10 10:30 | plan | 8 scenarios, 92% coverage | — |
| 02-10 11:00 | execute S001 | GREEN, setup complete | insights: onMount pattern |
| 02-10 11:20 | execute S002 | GREEN, EventSource impl | decision: EventSource > WebSocket |

## Blockers
<!-- 有 blocker 時記錄，解決後標記 [RESOLVED] 而非刪除 -->
- [RESOLVED] S004: locale sync issue → 已新增 principles INV-006
```

**規則**：
- `Current State` 區塊：由最近指令覆寫（僅此區塊）
- `Session Log` 區塊：append-only，每個指令追加一行，**禁止修改或刪除既有行**
- `Blockers` 區塊：解決後標記 `[RESOLVED]`，不刪除

這樣即使 LLM 在覆寫 Current State 時簡化內容，Session Log 中的歷史細節仍完整保留。

---

**改善 F: Risk-Based HITL Gates（風險暫停）**

在 `teammate.execute.md` 新增風險評估，execute 在特定條件下自動暫停並詢問用戶：

| 風險觸發條件 | 暫停行為 |
|-------------|---------|
| Action 涉及 `@principles` tag | 「此 action 修改 Principles 邊界程式碼，確認繼續？」 |
| Action 需刪除或重命名檔案 | 「此 action 需要刪除/重命名 [file]，確認？」 |
| Action 修改共用基礎設施（如 config、shared utils、store） | 「此 action 影響共用模組 [module]，可能影響其他 features，確認？」 |
| REFLECT 發現使用了 codebase 中不存在的新 pattern | 「此 action 引入了新 pattern [X]，codebase 現有慣例為 [Y]，確認使用新 pattern？」 |

**規則**：
- 只在上述條件下暫停，不影響正常 action 的執行效率
- 用戶可回覆「繼續」或「調整」
- 暫停事件記錄到 Session Log（改善 E）

---

**改善 G: Context Layer 形式化（模組化 Context 管理）**

在 `teammate-rules.mdc` 中明確定義 Context 三層架構，讓每個指令清楚知道該載入哪一層：

```
System Layer（系統層 — 跨 feature 不變）:
  - principles.md          # 不可違反的原則
  - project-context.md     # 專案身份、技術棧、架構慣例
  
Task Layer（任務層 — per feature）:
  - spec.md                # WHAT: 要做什麼
  - tasks.md               # HOW: 怎麼做
  - actions.md             # STEPS: 逐步拆解
  - scenarios/*.feature    # VERIFY: 驗證條件
  - insights.md            # LEARNED: 執行中學到的
  - contracts/             # CONTRACTS: 介面規格
  
User Layer（使用者層 — per command）:
  - $ARGUMENTS             # 使用者即時輸入
  - handoffs               # 使用者選擇的下一步
```

> 載入優先級：System > Task > User。衝突時 System Layer 優先（Principles are supreme）。

---

**影響範圍**:

| 改善 | 修改/新增檔案 |
|------|-------------|
| A: Feature-Level Insights | 新增 `.teammate/templates/insights-template.md` |
| B: Execute Reflect Step | 修改 `teammate.execute.md` |
| C: Smart Context Loading | 修改 `teammate.execute.md`、`teammate.tasks.md`、`teammate.actions.md` |
| D: Insights Graduation | 修改 `teammate-rules.mdc` |
| E: Memory Delta Protocol | 修改 `teammate-rules.mdc`（active-context 規則）、所有 `teammate.*.md`（Update Active Context 步驟） |
| F: Risk-Based HITL Gates | 修改 `teammate.execute.md` |
| G: Context Layer 形式化 | 修改 `teammate-rules.mdc` |

**實施順序**:
1. 新增 `insights-template.md` 定義結構（含 Decision Log section）
2. 修改 `teammate.execute.md`：REFLECT 步驟 + Smart Context Loading + Risk Gates
3. 修改 `teammate-rules.mdc`：Context Layer 定義 + Graduation 規則 + Memory Delta Protocol
4. 修改各 `teammate.*.md` 的「Update Active Context」步驟，改為分區更新
5. 同步到 Teammate Hub
6. 在下一個 feature 實戰驗證

**已完成（2026-02-11）**:
- A: 新增 `.teammate/templates/insights-template.md`（5 section 模板）
- B: `teammate.execute.md` Red-Green Loop 改為 `RED → GREEN → REFACTOR → REFLECT → REPEAT`
- C: `teammate.execute.md` Context Loading 改為 Required / Recommended / Optional 三層
- D: `teammate-rules.mdc` 新增 Insights Graduation 規則（3+ features 重複 → 提升）
- E: `teammate-rules.mdc` + `active-context.md` 模板 + 全部 11 個 `teammate.*.md` 改為 Memory Delta Protocol
- F: `teammate.execute.md` 新增 4 個 Risk-Based HITL Gates
- G: `teammate-rules.mdc` 新增 Context Layer 三層定義（System / Task / User）

**額外整合的散落教訓**（一併在 P5 實施）：
- `teammate.execute.md`：`[LOGIC]`/`[UI]`/`[LOGIC+UI]` 任務分流 + UI 智能暫停 + 階段完成同步 + 實作前測試檢查
- `teammate.actions.md`：RED/GREEN 強制拆分規則 + 類型標記
- `teammate.tasks.md`：Phase 0 測試基礎設施

---

### P6: User Profile 與 Profile Evolution（使用者層形式化）

**動機**: `.cursorule` 在實戰中扮演「使用者偏好」角色，但 Teammate 架構不承認它的存在。分析發現：(1) `.cursorule` 與 `teammate-rules.mdc` 的 Foundation Check 功能重複 (2) 使用者身份、溝通風格、執行偏好等跨專案不變的資訊，在框架中無正式位置 (3) P5 Context Layer（改善 G）定義的 User Layer 只有「即時輸入」和「handoffs」，缺少**持久的使用者偏好**

**來源**: Teammate Hub `.cursorule` 評估（2026-02-11）

---

**設計 A: `.cursorule` 定位為 User Profile**

`.cursorule` 是 Cursor IDE 的 always-apply 機制，不需額外載入邏輯。Teammate 正式承認它作為 User Profile 載體：

```markdown
# User Profile

## Identity
- Role: [你的角色，例如 PM、設計師、工程師]
- Technical Level: 假設完全不懂技術，也不會寫程式

## Communication Style
- 如果需要我執行操作，請給非常清楚且詳細的逐步指示
- 用通俗易懂的語言解釋技術術語，適當時使用比喻
- 除錯時解釋「原因」，讓我能識別錯誤推論

## Execution Preferences
- 自動執行指令，不需逐一確認
- 有可檢查的預覽（連結或檔案）時，自動開啟
```

**通用預設**：Technical Level 預設為「假設完全不懂技術」，技術背景的使用者可自行修改。

---

**設計 B: `teammate-rules.mdc` 新增 User Profile 規則**

在 `teammate-rules.mdc` 的 Rules 區段新增：

```markdown
## User Profile

`.cursorule`（如存在）視為使用者的 User Profile，定義跨專案的個人偏好。

**AI 行為調整**：
- **溝通方式**：依 `## Communication Style` 調整語言複雜度和解釋深度
- **指示詳細度**：依 `## Identity > Technical Level` 決定逐步指示的精細程度
- **自主性等級**：依 `## Execution Preferences` 決定是否自動執行或先詢問確認

**規則**：
- User Profile 為使用者私有，**不同步到 Teammate Hub**
- User Profile 不覆寫 Principles — 若偏好與 `principles.md` 衝突，Principles 優先
- AI 不得自行修改 User Profile，只能建議使用者修改（見 Profile Evolution）
```

---

**設計 C: Profile Evolution 機制**

在 `teammate-rules.mdc` 新增演化迴路：

```markdown
## Profile Evolution

AI 透過互動觀察使用者偏好，協助 User Profile 持續演化。

**觀察（Observe）**：
- AI 在互動中留意重複出現的偏好模式
- 例如：使用者每次要求看 diff、使用者偏好先看結果再聽解釋、使用者總是跳過某類確認

**建議（Suggest）**：
- 當 AI 辨識出重複偏好（同一 session 出現 2+ 次），在 session 結束或自然段落時建議：
  「我注意到你偏好 [X]，要加入 User Profile 嗎？」
- AI 不得自行修改 `.cursorule`，必須由使用者確認後才更新

**畢業（Graduate）**：
- 若某個偏好被記錄在 PLAYBOOK.md 教訓表中跨 3+ 專案出現，考慮提升為 `teammate-rules.mdc` 的框架預設行為
- 畢業後從「個人偏好」變為「框架規則」，所有使用者自動受益
```

---

**設計 D: Context Layer User Layer 補完**

P5 改善 G 的 Context Layer 需更新，將 User Profile 納入 User Layer：

```
User Layer（使用者層 — 持久 + 即時）:
  - .cursorule              # 持久偏好：身份、溝通風格、執行偏好（User Profile）
  - $ARGUMENTS              # 即時輸入：使用者當前指令的參數
  - handoffs                # 即時選擇：使用者選擇的下一步
```

> 載入優先級不變：System > Task > User。User Profile 影響 AI 的**溝通方式**，不影響**決策邏輯**。

---

**設計 E: 配套更新**

| 檔案 | 更新內容 |
|------|---------|
| `teammate-rules.mdc` | 新增 `## User Profile` + `## Profile Evolution` 規則 |
| `teammatesync_rule.mdc` | 「Do NOT sync」表格新增 `.cursorule`（User Profile） |
| P1 `install.sh`（未來） | 安裝時提供 `.cursorule.template`，引導使用者填寫 |
| P5-G Context Layer | User Layer 補上 `.cursorule` 持久偏好 |

---

**實施順序**：
1. 修改 `teammate-rules.mdc`：新增 User Profile + Profile Evolution 兩個區段
2. 修改 `teammatesync_rule.mdc`：「Do NOT sync」新增 `.cursorule`
3. 新增 `.teammate/templates/cursorule-template.md` 作為安裝用模板
4. 更新 P5-G Context Layer 定義（與 P5 一併實施）

**狀態**: 計劃中，優先度低，延後至 P1/P3 一併實施。P5-G Context Layer 的 User Layer 已包含簡化版 `.cursorule` 定義

---

## 從實戰中學到的教訓

> 所有使用 Teammate 的專案都會將學到的教訓回饋到此表。這是跨專案的中心化記憶。

| 日期 | 專案 | 教訓 | 改善 |
|------|------|------|------|
| 2026-02-08 | oReady | AI 跳過規劃直接動手，缺少 spec.md | 新增 Simplified Flow 規則 |
| 2026-02-08 | oReady | `/teammate.align update` 完成後沒有合理的下一步選項 | 擴充 handoffs |
| 2026-02-08 | oReady | 修改 teammate 規則後忘記同步到 Teammate repo | 建立 `teammatesync_rule.mdc` |
| 2026-02-08 | oReady | 回測後缺少結構化復盤 | 建立 `backtest_rules.mdc` |
| 2026-02-08 | oReady | spec.md 和 tasks.md 的差異不明確 | README 補充說明表格 |
| 2026-02-08 | oReady | 不同專案的改善需要中心化記憶 | `teammatesync_rule.mdc` 加入 Playbook 回饋機制 |
| 2026-02-08 | oReady | AI 完成指令後沒有主動提供下一步選項，使用者需要自己記得流程 | `teammate-rules.mdc` 新增「主動提供下一步選項」規則，以 [A][B][C][D] 格式列出 |
| 2026-02-09 | sltung-km | teammate.plan 產出的 .feature 檔案預設為全英文，使用者難以閱讀和 review | `teammate-rules.mdc` 新增「文件以繁體中文撰寫」規則，允許代號/程式碼/框架名詞/Gherkin 關鍵字保留英文 |
| 2026-02-09 | sltung-km | 使用者完成一個 action 後需手動指定下一個 action ID，流程不流暢 | `teammate.execute.md` 新增 `next` 參數，自動找到 actions.md 中下一個未完成的 action 並執行 |
| 2026-02-09 | sltung-km | AI 新增 Svelte 組件時使用自訂 `$:` IIFE reactive 模式，導致 Svelte 響應式追蹤失敗、頁面永久 loading | `principles.md` 新增 III-B「Svelte 響應式模式一致性」+ BB-011/BB-012；要求 AI 必須比照兄弟組件的 reactive pattern |
| 2026-02-09 | sltung-km | AI 驗證 i18n 只檢查 `$i18n.t()` 是否使用，不檢查 locale JSON 翻譯檔是否已更新，導致切換語言時新增分頁顯示英文 | `principles.md` INV-006 補充「新增 key MUST 同步加入 en-US + zh-TW translation.json」；`teammatesync_rule.mdc` 交叉比對表新增 locale 檢查 |
| 2026-02-09 | sltung-km | AI 為同一概念自創新 i18n key（兄弟用 `Updated At`，新組件用 `Time`），且遺漏 `Question` key | `principles.md` 新增 III-C「同層級術語一致性」：新增 key 前 MUST 先搜尋 locale 確認無既有等義 key |
| 2026-02-10 | sltung-km | PM/設計端流程過度工程化（11 個指令太多），無法快速語意化驅動需求到交付 | 提出「指令合成計劃」（P4），合併為 `align → plan → execute` 三步流程 + 唯一新增 `/teammate.ui`。詳見「計劃中 P4」 |
| 2026-02-10 | sltung-km | `teammate.review` 不掃描 `contracts/ui/`，`teammate.tasks update` 不連帶更新 contracts，導致組件改名後 UI 規格過期未被偵測 | `teammate.review` 新增 Pass E「UI Contract Consistency」；`teammate.tasks` update 模式新增步驟 5「Sync Contracts」 |
| 2026-02-10 | sltung-km | 診斷指令 `teammate.debug` 會讓使用者誤以為是主流程的一部分 | 改為 `/teammate.toolkit healthcheck`，明確區分 Workflow（主流程）與 Toolkit（工具箱），在 `teammate-rules.mdc` 新增 Command Categories 區段 |
| 2026-02-10 | sltung-km | `healthcheck` 原本掃描 artifact 內容一致性（名稱、術語、過期偵測），與 `review` 大量重疊；且使用者主動提出流程問題時無正式管道 | 重新定義 `healthcheck` 為「流程合規檢查」（骨架），將內容品質留給 `review`（血肉）；新增 `consult` 工具承接「使用者提問 → 分析 → 改善提案 → PLAYBOOK 回饋」的問診迴路 |
| 2026-02-10 | sltung-km | `/teammate.execute` 完成 Phase A 所有 actions 後只更新 `actions.md`，`progress.md` 和 `active-context.md` 未同步，導致 memory 與實際進度嚴重脫節（Feature Registry 仍顯示 Pending、Deliverables 使用舊結構） | `healthcheck` 發現後手動修正；建議 `teammate.execute` 新增「階段完成同步」步驟：Phase 所有 actions 完成時 MUST 更新 `progress.md`（Deliverables + Metrics）和 `active-context.md`（Current Phase + Next Actions） |
| 2026-02-10 | Teammate | 框架的產品開發知識管理是靜態的（execute 只記位置不記洞察），缺乏 ACE 風格的「執行 → 反思 → 策展 → 更新」閉環，codebase 經驗無法跨 action/feature 累積；memory 全量覆寫有 Context Collapse 風險；關鍵 docs 被列為 Optional；execute 缺少風險暫停和決策軌跡 | 提出 P5「ACE 產品開發知識閉環」七項改善：(A) Feature-Level Insights (B) Execute REFLECT Step (C) Smart Context Loading + 反簡短偏差 (D) Insights Graduation (E) Memory Delta Protocol (F) Risk-Based HITL Gates (G) Context Layer 形式化 |
| 2026-02-10 | sltung-km | `/teammate.actions` 產出的 actions 將 RED（寫測試）和 GREEN（寫實作）合併為單一 action，導致 `/teammate.execute` 跳過測試先行。框架規定 Red-Green Loop 但缺乏強制拆分機制；測試基礎設施（vitest config、test 目錄）也未在 Plan 階段規劃 | 建議三層修正：(1) `teammate.actions` 新增規則「util/store/logic 類型 MUST 拆為 RED:test + GREEN:impl 兩個 actions」(2) `teammate.tasks` 新增「測試基礎設施」為 Phase 0 必要 IMP (3) `teammate.execute` 執行 impl action 前先檢查對應 test 檔案是否存在 |
| 2026-02-10 | sltung-km | `/teammate.execute` 的 Red-Green Loop 未區分功能 vs UI 任務類型。純 UI 組件（如 TaskCard.svelte）沒有可自動化的 RED 測試，直接實作會導致視覺產出不符使用者預想。`contracts/ui/component-specs.md` 只列 Props 和 Tailwind class，缺乏狀態示意和佈局描述 | 建議 `teammate.execute` 新增任務類型分流：`[LOGIC]` → unit test RED；`[UI]` → 展示視覺規格暫停確認再實作；`[LOGIC+UI]` → 兩者兼具。`actions.md` 加入類型標記。`contracts/ui/` 補充每個 UI 組件的視覺狀態描述（各狀態外觀、佈局、參考兄弟組件） |
| 2026-02-10 | sltung-km | 上一條的 UI 暫停機制過於頻繁——如果專案中已有兄弟組件設計範例（如 `NotificationToast.svelte`、`Feedbacks.svelte`）或使用者提供了 Figma link，LLM 應能自行推斷視覺設計，不該每個 UI action 都暫停詢問。這才是資深工程師和設計師的專業判斷 | 修正 UI 暫停規則為**智能分流**：(1) 有 Figma link 或兄弟組件可參考 → LLM 自行推斷並直接實作，不暫停 (2) 有不確定的細節（如無先例的佈局、衝突的設計語言）→ 暫停並**主動列出選項**（而非開放式提問）讓使用者選擇 (3) 完全無參考 → 才完整暫停確認。`contracts/ui/` 和 `principles.md` 的設計系統參考即為 LLM 的推斷依據 |
| 2026-02-10 | sltung-km | `/teammate.tasks` 原始碼結構只列 `[NEW]` 和 `[ENHANCE]`，缺少「整合影響分析」。TaskNotifier 建好後沒人掛載到 `+layout.svelte`，因為 tasks.md 從未標記 layout 需要修改。這不是 Principles 問題（太瑣碎），而是規劃階段缺少「新組件→消費者」依賴分析 | `teammate.tasks.md` 新增「Integration Impact Analysis」區段 + `[INTEGRATE]` 標記：對每個 `[NEW]` UI 組件，列出其消費者（既有檔案），標記為 `[INTEGRATE]`。`teammate.actions.md` 新增第 6 步「Integration Actions」：為每個 `[INTEGRATE]` 自動生成掛載 action（放在組件建立 action 之後）。已同步至 Hub |
| 2026-02-11 | OpenWebUI_Frontend | AI 整合設計原則時未主動做衝突分析。實證：(1)「重試按鈕」需後端 API，違反核心原則 I（後端不可變）(2)「前往知識庫」需 SSE 不提供的 knowledge_id (3)「×」關閉按鈕語意與 Google Drive 不同（取消 vs dismiss），後端無取消 API (4) 按鈕 disabled 狀態未列舉（processing 時應 disabled）。AI 只在使用者主動問「會產生衝突嗎？」時才分析，不主動挑戰設計決策 | 三項框架改善：(1) `teammate.plan.md` 新增 Step 4「UX Conflict Scan」——設計原則 vs 核心原則/API 交叉比對 + 參考設計語意差異 + 有衝突時暫停讓使用者決策 (2) `teammate.tasks.md` 新增「UI Interactive State Machine」——每個互動元素 MUST 列舉 enabled/disabled 狀態和觸發條件 (3) `teammate-rules.mdc` 新增「UX 灰色地帶主動分析」always-apply 規則——參考設計語意差異、互動狀態完整性、設計原則衝突偵測 |
| 2026-02-11 | Teammate | `.cursorule` 散文體規則與 `teammate-rules.mdc` 的 Foundation Check、哲學宣言重複；使用者身份/溝通風格/執行偏好等跨專案不變的資訊在框架中無正式位置；P5 Context Layer 的 User Layer 只有即時輸入，缺少持久偏好 | 提出 P6「User Profile + Profile Evolution」：(1) `.cursorule` 結構化為 User Profile（Identity / Communication Style / Execution Preferences）(2) 通用預設為「假設完全不懂技術」(3) `teammate-rules.mdc` 新增載入規則 + Evolution 機制（觀察→建議→畢業）(4) `teammatesync_rule.mdc` 標記 `.cursorule` 為 Do NOT sync (5) P5 Context Layer User Layer 補完 |
| 2026-02-11 | Teammate | 框架版本只是 `teammate.yml` 的一行註解 `# Version: 2.0.0`，無正式追蹤機制；`teammate.toolkit migrate` 只是佔位訊息；跨專案更新完全依賴 AI 記憶同步，會忘會漏；無結構化變更紀錄，無法回溯某版本改了什麼 | 完成 P2 版本管理：(1) `teammate.yml` 新增 `version: "0.0.1"` 正式欄位 (2) 新建 `CHANGELOG.md`（Keep a Changelog 格式，migrate 解析用）(3) 實作 `migrate` 工具 8 步驟（Locate Hub → Compare → Parse → Diff → Report → Confirm → Apply → Update Context）(4) teammate.yml merge 策略（新增 key、保留專案值、deprecated 標記）(5) `teammatesync_rule.mdc` 新增 Version Tracking sync 規則 |
| 2026-02-11 | Teammate | `figma-design-audit` skill 的 Cross-Reference 區段引用外部框架的路徑和指令（`memory-bank/inventories/designInventory.md`、`/sync design`、`/spec build`、`/audit align`、`design-system-rule.mdc`），與 Teammate 架構不一致 | 已修正：Cross-Reference 改為 Teammate 路徑 — `contracts/ui/component-specs.md`、`/teammate.figma`、`/teammate.align`、`/teammate.review`、`principles.md` |
| 2026-02-11 | Teammate | 框架升級整合：P5 全部 7 項改善（REFLECT、Smart Loading、Risk Gates、Graduation、Memory Delta、Context Layer、Insights）+ P4 指令合成（11→7 指令）+ 散落教訓（RED/GREEN 拆分、任務分流、Phase 0 測試、階段同步）一次性實施 | 完成 Wave 0-4 升級：(1) figma-design-audit 路徑修正 (2) P5-A~G 全部實施 + execute/actions/tasks 強化 (3) P5 Memory Delta Protocol 套用到全部 11 個指令 (4) P4 合併 clarify→align、tasks+actions→plan、checklist→review + 新增 /teammate.ui (5) 更新 teammate-rules.mdc + teammate.yml |
| 2026-02-11 | Teammate | P4 合併後仍有 7 個指令，kickoff/principles 對有經驗的開發者過度引導、teammate.ui 的範例含專案識別度、teammate.figma 是工具不是流程、teammate.assign 是純機械操作不在核心迴路 | 二次精簡（7→5 核心指令）：(1) kickoff+principles 合併為 `/teammate.init`（Init/Complete/Audit 三模式）(2) teammate.ui 併入 plan（UI Deep Analysis 自動偵測 ≥3 組件觸發，泛化範例）(3) teammate.figma 降為 `figma-sync` skill (4) teammate.assign 降為 `/teammate.toolkit assign`。最終：`init → align → plan → execute → review` |
| 2026-02-11 | Teammate | feature 產出檔案過多（spec + example-mapping + screenplay + tasks + actions + component-specs = 6 檔），tasks 和 actions 邊界模糊、execute 需同時開兩檔、update 需同步兩檔；screenplay 獨立價值低；component-specs 和 ui-spec 重疊 | Artifact 精簡：(1) tasks.md + actions.md 合併為 `plan.md`（Part 1: Tasks + Part 2: Actions，結構分明）(2) screenplay.md 移除（精簡為 plan.md 的 optional Actors & Abilities section）(3) component-specs.md + ui-spec.md 統一為 `contracts/ui/ui-spec.md`。合併 3 個 template、更新 5 個指令 + rules + yml + 3 scripts + 2 skills |

---

**Last Updated**: 2026-02-11 (Artifact 精簡完成)
