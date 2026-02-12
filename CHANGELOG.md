# Changelog

All notable changes to the Teammate framework are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). This file is parsed by `/teammate.toolkit migrate` to generate migration plans.

> **版本語意**：0.x.y 階段為快速迭代，不保證向後相容。1.0.0 起遵循 semver（MAJOR = 破壞性變更，MINOR = 新功能，PATCH = 修正）。

---

## [Unreleased]

> 累積中的變更，尚未歸入版本號。下次發行時移到具體版本區段。

### Summary
指令精簡（11→5+audit）、artifact 合併、目錄與檔名重整、動態合規監控、設計資產動態建立。**包含多項破壞性變更**，既有專案需執行 `/teammate.toolkit migrate`。

### Added
- `/teammate.audit` 指令 — Sarcasmotron 對抗性合規審計（Security + Design Debt + 動態 A11y + 動態 AI Risk）
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
