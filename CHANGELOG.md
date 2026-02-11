# Changelog

All notable changes to the Teammate framework are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). This file is parsed by `/teammate.toolkit migrate` to generate migration plans.

> **版本語意**：0.x.y 階段為快速迭代，不保證向後相容。1.0.0 起遵循 semver（MAJOR = 破壞性變更，MINOR = 新功能，PATCH = 修正）。

---

## [Unreleased]

> 累積中的變更，尚未歸入版本號。下次發行時移到具體版本區段。

### Summary
（待定）

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
