# Changelog

All notable changes to the Teammate framework are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). This file is parsed by `/teammate.helpme migrate` to generate migration plans.

> **版本語意**：0.x.y 階段為快速迭代，不保證向後相容。1.0.0 起遵循 semver（MAJOR = 破壞性變更，MINOR = 新功能，PATCH = 修正）。

---

## [Unreleased]

> 累積中的變更，尚未歸入版本號。下次發行時移到具體版本區段。

### Added
- (無)

### Changed
- (無)

### Documentation
- (無)

---

## [0.4.0] - 2026-03-05

### Added
- **設計任務處理路徑（Design Mode）** — `teammate-rules.mdc` 新增設計任務條文，定義 `.pen` / Figma 設計稿變更為「設計文件更新」（與 `spec.md` 同級），允許設計稿修改先於 `spec.md`，完成後 MUST 補產 `contracts/ui/ui-spec.md`
- **`teammate.align` Design Mode 分流** — 模式偵測新增 Design Mode：偵測 Pencil node IDs / `.pen` 路徑 / 設計關鍵字時，Impact Mapping 簡化為 Design Intent Mapping，產出 `contracts/ui/ui-spec.md`，Example Mapping 變為可選
- **`[DESIGN]` action 類型** — `teammate.plan.md` 新增 `[DESIGN]` 類型（設計稿修改），MUST 排在同 story 的 `[UI]`/`[LOGIC]` actions 之前；階段結構新增 Phase 1: Design（無設計則跳過）；行動原則新增「設計先於程式」
- **`[DESIGN]` 執行支援** — `teammate.execute.md` Action 類型偵測表新增 `[DESIGN]`（RED: Acceptance Scenarios / GREEN: 設計稿修改 + 截圖驗證），實作執行規則新增「設計先於程式」排序
- **`context-template.md` 設計欄位** — Design References 新增 `Design Tool` 欄位，加入設計稿修改須遵循 Align → Plan → Execute 流程的聲明
- **`teammate-sync.sh`** — 跨平台同步腳本，將 `dist/` 分發至消費專案。支援 Cursor (`.cursor/`)、Claude Code (`.claude/`)、Antigravity (`.agent/`)，含自動平台偵測、`--dry-run` 模式、版本追蹤 (`.teammate-sync-version`)、`--check`（比對遠端 Hub 版本）、`--self-update`（拉取最新 Hub 後同步）
- **Claude Code 同步** — commands → `.claude/commands/`（移除 `handoffs`，保留 `$ARGUMENTS`）、rules `.mdc` → `.claude/rules/*.md`（保留 `description`/`globs`）、skills 直接複製（格式完全相容）
- **Antigravity rules 轉換** — `.mdc` → `.md`，自動依 frontmatter (`alwaysApply`/`globs`/`description`) 產生 activation metadata (`always_on`/`glob`/`model_decision`/`manual`)
- **Antigravity workflows 轉換** — Cursor commands → Antigravity workflows，加入 `title`/`description` frontmatter，移除 Cursor 專屬欄位 (`handoffs`/`$ARGUMENTS`)
- **`dist/agents` 同步支援** — `teammate-sync.sh` 三個平台（Cursor / Claude Code / Antigravity）均新增 `dist/agents` → `{platform}/agents` 同步
- **agents 重組** — `agent-orch.md` → `agent-orchestrator.md`、`architect.md` → `code-architect.md`、`fe-designer.md` → `designer.md`、`k8s-ops.md` → `kubernetes-operator.md`；新增 `pencil-dev.md`（聚焦 Pencil MCP 呼叫）
- **pencil commands 重組** — `frontend-design/pencil.tokens.bind.md` / `pencil.tokens.generate.md` 移至 `pencil/tokens.bind.md` / `tokens.generate.md`

### Changed
- **反饋閉環補強** — `teammate.plan.md` 載入額外脈絡新增條件必載：最近 2 個已完成任務的 `insights.md`（規劃階段可參考歷史教訓）；`teammate.execute.md` REFLECT 自檢清單新增第 6 點：Insight Graduation 判斷（3+ 次重複 → 建議畢業），顯式引用 `@teammate-reference`；`teammate.align.md` 基礎檢查後新增條件載入：最近 1 個已完成任務的 `insights.md`（UX/設計類教訓影響需求品質）
- **REFLECT 迭代追蹤規則** — `teammate-rules.mdc` REFLECT 責任鏈新增第三條：已完成 action 因使用者回饋、設計審查或錯誤修正而再次修改時，MUST 在 `insights.md` 追加迭代紀錄；適用範圍不限 `/teammate.execute`。`teammate.execute.md` REFLECT Phase 同步追加迭代追蹤條目
- **`teammate-designrule.mdc` 整合至 `.cursorule`** — Sync Rule 三項規範（框架檔案同步、版本追蹤、教訓回饋）併入 `.cursorule` 同步規範區段，刪除獨立 `teammate-designrule.mdc`（符合無冗餘原則：Rule 不重複存放相同約束）
- **`context/` → `dist/`** — 分發資料夾重新命名，語意更精準：`dist/` 明確表示「可分發至使用專案的 AI 上下文套件」。Antigravity 等其他平台將另以 workflow 同步，不在 `dist/` 內建立子目錄

### Documentation
- (無)

---

## [0.3.1] - 2026-03-02

### Added
- **AskQuestion 決策介面** — 重大決策（System Scope 變更、UX 衝突、UI 設計歧異）改用 `AskQuestion` tool 產生正式選項介面，取代純文字 `[Y]/[N]` 標籤
- **check-foundation.sh** — Foundation 檢查集中化為 bash script，提供統一的 context.md / principles.md 驗證
- **teammate-reference skill** — 工作流程、檔案結構、記憶機制等參考資訊封裝為 `.cursor/skills/teammate-reference/SKILL.md`，按需載入以節省 token
- **架構原則** — `.cursorule` 新增「精簡、精煉、言簡意賅」：權責分明（Rules / Commands / Skills）、無冗餘原則、實踐檢驗三問
- **figma-rules.mdc** — 精簡版 Figma 核心約束（~80 行），取代 537 行 rule
- **figma.to.code.md** — 完整 Figma → Code Agent 移至 `.cursor/commands/`（按需載入）

### Changed
- **teammate-rules 參考型資訊拆分** — 工作流程詳表、關鍵路徑、脈絡層級、洞察畢業、記憶差量細節、中途更新自 rules 搬至 `teammate-reference`，rules 改以 `@teammate-reference` 引用
- **AI Persona 精簡** — 「現象學共創型智能體」→「共創型協作者」，移除哲學術語；溝通風格 5 條敘事 → 3 條操作規則
- **Memory Delta Protocol 瘦身** — `teammate-rules.mdc` 僅保留 3 條硬規則，欄位對照表與範例僅存 `teammate-reference`，消除 rules/reference 重複
- **架構優化**：Foundation 檢查集中化為 `check-foundation.sh`，消除 3 個指令（align/plan/init）的重複邏輯
- **架構優化**：System Scope 改為單一來源（`plan.md` 產生，execute/review/audit 只讀取），消除重複偵測
- **架構優化**：Memory Delta Protocol 抽成 `teammate-rules.mdc` 共用規範，7 個指令改為引用
- **體驗優化**：`execute` DIALOGUE 階段 System Scope 更新改為 Y/N 確認模式（原為 A/B/C 選項）
- **邊界釐清**：明確定義 `helpme` healthcheck（骨架存在性）vs `review`（語意完整性）職責分界
- **teammate-rules.mdc 精煉** — 刪除重複敘述、操作意涵合併入細則、REFLECT 副作用改表格、約 338→155 行（-54%）
- **teammatesync_rule.mdc 精煉** — 消除檔案清單重複、合併 Rules，約 88→42 行（-52%）
- **git-conventions.mdc 精煉** — 僅引用 Conventional Commits 官方規範，刪除重複定義與 MCP Git 章節，約 384→54 行（-86%）
- **Figma 架構重組** — `figma-to-code.mdc`（rule）→ `figma.to.code.md`（command）；新增 `figma-rules.mdc`（精簡 rule）
- **pencil-rules.mdc** — 移除 Figma 品質檢查與實作流程（183 行），保留純 `.pen` 操作

### Removed
- **figma-to-code.mdc** — 內容移至 `figma.to.code.md` command
- **figma.design.system.md** — 與 `create-design-system-rules` skill 重複
- **pencil.figma.extract.md** — Pencil tokens 主要源自 Tailwind，不需 Figma ↔ Pencil diff

### Documentation
- 新增 Memory Delta Protocol 實作規範（`teammate-rules.mdc`）
- 新增 Healthcheck vs Review 分界說明（`teammate.helpme.md`）
- teammate-reference 從 rules 移至 skills，核心規則改以 `@teammate-reference` 引用
- PLAYBOOK.md 新增 2026-02-25 架構精簡軌跡

---

## [0.3.0] - 2026-02-20

### Summary
對話式演化與自動驗證 — Execute ⟷ Spec 雙向同步、每個 action 自動驗證、精準追蹤多層級系統（Frontend / Backend / LLM）。框架完全符合五項憲法級核心價值。

### Added
- **System Scope Detection** — `/teammate.plan` 自動偵測專案涉及的系統層級（Frontend / Backend / LLM / Database / Mobile），產出到 `plan.md` 開頭的 System Scope 表格
- **DIALOGUE 階段** — `/teammate.execute` 新增對話式同步機制，在 REFLECT 後自動偵測規格外行為與系統層級變更，對話確認後同步到 spec.md
- **VERIFY 階段** — `/teammate.execute` 新增自動驗證執行，每個 action 完成後自動執行對應的 Gherkin scenarios
- **Change Log** — `spec-template.md` 新增 Change Log 區段，記錄規格演化歷史
- `verification.auto_run` 配置 — `teammate.yml` 新增自動驗證設定（test_command, framework_detection, fail_fast）
- **System Scope 模板** — `plan-template.md` 新增 System Scope 表格模板

### Changed
- **Red-Green-Refactor-Reflect → Red-Green-Verify-Refactor-Reflect-Dialogue** — `/teammate.execute` 迴圈從 4 階段擴充為 6 階段
- **動態維度偵測邏輯** — `/teammate.review` 和 `/teammate.audit` 從「掃描 codebase」改為「讀取 plan.md System Scope 表格」，保證檢查範圍與實作一致
- **REFLECT 驅動 DIALOGUE** — DIALOGUE 不是每次都觸發，由 REFLECT 分類決定（重構/無發現 → 跳過，新功能且超出 Verifies 範圍 → 觸發）
- **首次測試指令確認** — VERIFY 階段在 task 首次執行時會顯示偵測到的測試指令，確認後記住，後續不再詢問
- **環境錯誤分流** — VERIFY 階段區分「測試失敗」（RED）和「環境錯誤」（exit code 異常），不混為一談
- **術語統一** — 修正 v0.1.0 遺留的術語不一致：模板中 `Feature Specification` → `Task Specification`，`Feature Branch` → `Task Branch`（與 `tasks/` 目錄名一致）

### Documentation
- **ROADMAP.md** — 新增 P0: Meta Context 分層（元循環支援），記錄「用 Teammate 開發 Teammate」的 context 區隔方案

### Migration Notes
- 既有專案無需遷移（向後相容）
- `verification.auto_run` 預設啟用，如不需要可在 `teammate.yml` 設為 `enabled: false`
- DIALOGUE 階段會在 execute 時自動觸發，使用者可選擇跳過或稍後處理
- System Scope 會在 plan 時自動產生，無需手動設定

---

## [0.2.0] - 2026-02-15

### Summary
helpme 取代 toolkit、現象學共創型智能體 Persona、agent-spec 載入、review/helpme 任務結束版控提醒、REFLECT 強制關卡。既有專案可執行 `/teammate.helpme migrate` 取得更新。

### Added
- `.teammate/memory/agent-spec.md` — AI Agent 行為規範（角色、安全圍欄、對話策略），適用於有明確 AI Agent 的專案
- Context Layer System Layer 新增 `agent-spec.md` 載入支援
- **`/teammate.helpme` 智慧導航指令** — 取代 `/teammate.toolkit`，新增 Smart Navigator 模式：偵測專案狀態自動推薦下一步，首次使用者引導流程
- **AI Persona（現象學共創型智能體）** — `teammate-rules.mdc` 整合 `phenomenological-co-design-agent.md` 五項憲法級行為原則 + 溝通風格

### Changed
- **`teammate.review` 任務結束版控提醒**：當 Readiness 為 Ready 且無 CRITICAL/HIGH 時，報告結尾**必須**詢問「是否要 commit 並 merge 回 main？」；新增小節「任務結束且無需修正時（務必執行）」與 Report Completion 條款；review 唯讀不代為執行 Git，僅提示流程
- **`teammate.helpme` merge 版控**：進度偵測「Review 完成」時提醒版控流程（commit → checkout main → merge）；新增「任務結束後的版控流程」小節，與 review 結尾詢問一致
- **`/teammate.toolkit` → `/teammate.helpme`**：指令改名，更直覺。所有引用已更新（rules、README、CHANGELOG、review、teammatesync_rule）
- Smart Context Loading 更新：`teammate.execute` 和 `teammate.plan` 在 Recommended 層級加入 `agent-spec.md`（如存在則載入）
- **互動式選項格式規範**：AI 提供多選項時，統一使用 `[A] / [B] / [C]` 字母標籤格式，讓使用者可快速回覆字母選擇
- **REFLECT Hard Gate**：`teammate.execute` 的 REFLECT 步驟從 optional 升級為 mandatory gate — 每個 action 完成後必須寫入 `insights.md`（有發現寫內容，無發現寫 `No new insights`），禁止批次補寫
- **Red-Green → Red-Green-Reflect**：`teammate-rules.mdc` Rules 區段將 discipline 名稱更新，明確 REFLECT 為 hard gate

### Documentation
- 更新 README.md 專案結構，加入 `agent-spec.md` 說明
- 更新 `.teammate/memory/README.md`，加入 `agent-spec.md` 修改時機對照
- 更新 `teammate-rules.mdc` Context Layer 說明，System Layer 加入 `agent-spec.md`
- 強化 `teammate-rules.mdc` Output Mode 區段，明確定義「下一步格式」與「互動式決策格式」
- 修正 `figma-design-audit` skill 的 inventory 路徑引用（`inventories/` → `.teammate/design/`）

---

## [0.1.0] - 2026-02-13

### Summary
指令精簡（11→5+audit）、artifact 合併、目錄與檔名重整、動態合規監控、設計資產動態建立。**包含多項破壞性變更**，既有專案需執行 `/teammate.toolkit migrate`。

### Added
- `/teammate.audit` 指令 — Sarcasmotron 對抗性合規審計（Security + Design Debt + 動態 A11y + 動態 AI Risk）
- `.teammate/templates/context-template.md` — context.md 的獨立模板檔案
- `.teammate/templates/principles-template.md` — principles.md 的獨立模板檔案
- `.teammate/design/` 目錄 — 設計資產（由 `/teammate.align` 動態建立，偵測 `context.md` 有 Figma URL 時觸發）
- `/teammate.align` Figma URL 動態偵測 — 自動建立 `.teammate/design/figma-index.md`
- `/teammate.plan` 設計資產偵測 — 偵測 `figma-index.md` 存在時啟用 UI Deep Analysis
- `ai-compliance` skill — AI 風險合規實作指南 + Pass/Fail 代碼範例（動態偵測 LLM 才載入）
- `a11y-compliance` skill 新增動態偵測邏輯（偵測前端才載入）
- `docs/a11y-compliance/` — A11y 法規背景（LLM 友善格式）
- `docs/ai-compliance/` — AI 法規背景（LLM 友善格式）
- `teammate.review` Pass G: Design System Compliance（Token 合規 + 視覺偏移）
- `teammate.review` Pass D: Compliance Coverage（動態 A11y + AI Risk 初步檢查）
- `teammate.plan` Compliance Detection（動態偵測前端/AI 並提醒合規要求）
- `teammate.execute` Compliance Skills 載入（動態偵測後載入對應 skill）

### Changed
- **省 Token 混合模式** — `teammate-rules.mdc` 新增 Output Mode 輸出契約（Lean / Diagnostic / Blocker），大幅縮減日常指令回覆長度
- **下一步格式精簡** — 移除 ABCD 多選 + 時間段休息選項，改為單一推薦下一步
- **`.cursorule` 新增省 Token 原則** — 禁止廢話、冗餘輸出、多選格式
- **Commands 精簡 11→5**：`init → align → plan → execute → review`（+ toolkit）
- `teammate.align` 合併 `teammate.clarify`（Example Mapping 移入 align Phase 5）
- `teammate.plan` 合併 `teammate.tasks` + `teammate.actions`（輸出 `plan.md`）
- `teammate.review` 合併 `teammate.checklist`
- `teammate.init` 合併 `teammate.kickoff` + `teammate.principles`（Init/Complete/Audit 三模式）
- `teammate.assign` 降為 `/teammate.toolkit assign`
- `teammate.figma` 降為 `figma-sync` skill
- `teammate.ui` 併入 `teammate.plan`（UI Deep Analysis 自動偵測 ≥3 組件觸發）
- `tasks.md` + `actions.md` 合併為 `plan.md`（Part 1: Architecture + Part 2: Actions）
- `component-specs.md` + `ui-spec.md` 統一為 `contracts/ui/ui-spec.md`
- `screenplay.md` 移除
- `features/` 目錄重命名為 `tasks/`
- Memory 檔名重整：`project-context.md` → `context.md`、`active-context.md` → `progress.md`、`progress.md` → `milestone.md`
- `create-new-feature.sh` 重命名為 `create-new-task.sh`
- `plan.md` Part 1 從 "Tasks" 改為 "Architecture"
- `teammate.execute` 新增 Red-Green-Refactor-Reflect 四步迴圈（加入 REFLECT）
- `teammate.execute` 新增任務類型分流（`[LOGIC]`/`[UI]`/`[LOGIC+UI]`）
- `teammate.execute` 新增 Risk-Based HITL Gates（4 個暫停條件）
- `teammate.execute` 新增 Staleness Check（spec.md vs plan.md 時間比對）
- `teammate.align` update 模式新增 Downstream Impact Check
- Memory Delta Protocol：`progress.md`（原 active-context）改為分區更新模式
- Context Loading 改為 Required/Recommended/Optional 三層

### Added
- `/teammate.init` 指令（合併 kickoff + principles）
- `/teammate.toolkit assign` 子指令
- `figma-sync` skill（從 teammate.figma 降級）
- `.teammate/templates/insights-template.md`
- `.teammate/templates/plan-template.md`（合併 task + actions template）
- Insights Graduation 機制（3+ 次重複 → 提升到 context/principles）
- Context Layer 形式化（System/Task/User 三層）
- `teammate-rules.mdc` > UX 灰色地帶主動分析規則

### Removed
- `teammate.kickoff.md`（併入 init）
- `teammate.principles.md`（併入 init）
- `teammate.clarify.md`（併入 align）
- `teammate.tasks.md`（併入 plan）
- `teammate.actions.md`（併入 plan）
- `teammate.checklist.md`（併入 review）
- `teammate.assign.md`（降為 toolkit）
- `teammate.figma.md`（降為 skill）
- `teammate.ui.md`（併入 plan）
- `.teammate/templates/task-template.md`（併入 plan-template）
- `.teammate/templates/actions-template.md`（併入 plan-template）
- `.teammate/templates/screenplay-template.md`（移除）
- `docs/llms.txt`（改為專案選用，不預設存在）
- `docs/design/figma-index.md`（移至 `.teammate/design/`，由 align 動態建立）

### Framework Files（目前清單）

**Rules**
- `.cursor/rules/teammate-rules.mdc`
- `.cursor/rules/teammatesync_rule.mdc`

**Commands（6 個）**
- `.cursor/commands/teammate.init.md`
- `.cursor/commands/teammate.align.md`
- `.cursor/commands/teammate.plan.md`
- `.cursor/commands/teammate.execute.md`
- `.cursor/commands/teammate.review.md`
- `.cursor/commands/teammate.toolkit.md`

**Templates**
- `.teammate/templates/spec-template.md`
- `.teammate/templates/example-mapping-template.md`
- `.teammate/templates/feature-template.feature`
- `.teammate/templates/plan-template.md`
- `.teammate/templates/insights-template.md`
- `.teammate/templates/checklist-template.md`
- `.teammate/templates/agent-file-template.md`

**Scripts**
- `.teammate/scripts/bash/common.sh`
- `.teammate/scripts/bash/check-prerequisites.sh`
- `.teammate/scripts/bash/create-new-task.sh`
- `.teammate/scripts/bash/setup-task.sh`
- `.teammate/scripts/bash/update-agent-context.sh`

**Skills**
- `.cursor/skills/figma-sync/SKILL.md`
- `.cursor/skills/figma-design-audit/SKILL.md`

**Config**
- `.teammate/config/teammate.yml`

**Memory**
- `.teammate/memory/context.md`
- `.teammate/memory/principles.md`
- `.teammate/memory/progress.md`
- `.teammate/memory/milestone.md`

### Migration Notes
- 既有專案的 `features/` 目錄需手動重命名為 `tasks/`
- `tasks.md` + `actions.md` 需手動合併為 `plan.md`（或重新執行 `/teammate.plan`）
- `project-context.md` → `context.md`、`active-context.md` → `progress.md`、`progress.md` → `milestone.md` 需手動重命名
- `screenplay.md` 可安全刪除（內容已整合到 plan.md Actors & Abilities section）
- 刪除已移除的指令檔案（kickoff/principles/clarify/tasks/actions/checklist/assign/figma/ui）
- `docs/llms.txt` 不再預設存在；如專案使用第三方 API/SDK，可自行建立
- `docs/design/figma-index.md` 移至 `.teammate/design/figma-index.md`；該檔案由 `/teammate.align` 動態建立（當 `context.md` 包含 Figma URL 時）

---

## [0.0.1] - 2026-02-11

### Summary
框架初始版本，建立版本追蹤機制與遷移工具。

### Added
- `teammate.yml` > `version` 正式欄位（從 `# Version: 2.0.0` 註解升級）
- `CHANGELOG.md`（本檔案）— 結構化版本發行紀錄
- `teammate.toolkit.md` > `migrate` 工具實作（取代佔位訊息）

### Framework Files（baseline 清單）

以下為本版本追蹤的所有框架檔案，作為遷移比對的 baseline：

**Rules**
- `.cursor/rules/teammate-rules.mdc`
- `.cursor/rules/teammatesync_rule.mdc`

**Commands（13 個）**
- `.cursor/commands/teammate.kickoff.md`
- `.cursor/commands/teammate.principles.md`
- `.cursor/commands/teammate.align.md`
- `.cursor/commands/teammate.clarify.md`
- `.cursor/commands/teammate.plan.md`
- `.cursor/commands/teammate.tasks.md`
- `.cursor/commands/teammate.actions.md`
- `.cursor/commands/teammate.execute.md`
- `.cursor/commands/teammate.review.md`
- `.cursor/commands/teammate.checklist.md`
- `.cursor/commands/teammate.assign.md`
- `.cursor/commands/teammate.toolkit.md`
- `.cursor/commands/teammate.figma.md`

**Templates（8 個）**
- `.teammate/templates/spec-template.md`
- `.teammate/templates/example-mapping-template.md`
- `.teammate/templates/feature-template.feature`
- `.teammate/templates/task-template.md`
- `.teammate/templates/actions-template.md`
- `.teammate/templates/screenplay-template.md`
- `.teammate/templates/checklist-template.md`
- `.teammate/templates/agent-file-template.md`

**Scripts（5 個）**
- `.teammate/scripts/bash/common.sh`
- `.teammate/scripts/bash/check-prerequisites.sh`
- `.teammate/scripts/bash/create-new-feature.sh`
- `.teammate/scripts/bash/setup-task.sh`
- `.teammate/scripts/bash/update-agent-context.sh`

**Config**
- `.teammate/config/teammate.yml`

### Migration Notes
- 這是第一個追蹤版本，專案若無 `version` 欄位視為 pre-tracking
- pre-tracking 專案執行 migrate 時會做全量檔案比對
