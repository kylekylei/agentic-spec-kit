# Changelog

Format follows [Keep a Changelog](https://keepachangelog.com/).

> **版本語意**：0.x.y 階段為快速迭代，不保證向後相容。1.0.0 起遵循 semver。

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

## [0.7.1] - 2026-04-03

### Changed

- **`AGENTS.md` → `CLAUDE.md`** — 重命名為 Claude Code 專屬參考，移除多平台欄位（74→28 行）
- **`Hub` → `Source`** — 全局術語替換，消除「中心化服務」歧義；`~/.speckit-hub` → `~/.speckit`
- **`PLAYBOOK.md` 移除** — 刪除所有引用（rules、speckit references）；教訓回饋區段移除
- **`dist/` → `templates/` 修正** — 清理 `docs/architecture.md`、`docs/extension-api-reference.md`、`.claude/rules/speckit.md`、`.cursor/rules/speckit.mdc` 的殘留 `dist/` 路徑
- **`speckit-rules.mdc`** — 統一 `@speckit` → `speckit/` 引用風格
- **`speckit.validate.md`** — 移除已刪 skills 引用，精簡 validation dimensions

### Removed

- **Skills（7 個）**：`web-artifacts-builder`、`tailwind-design-system`、`typescript-advanced-types`、`web-component-design`、`code-documentation`、`responsive-design`、`visual-design-foundations`、`ai-compliance`
- **`skill-creator`** — 從 registry 和腳本移除（目錄不存在）
- **`skill-registry.yml` 分類**：`frontend_tailwind`、`frontend_typescript` 空分類移除
- **`snapshots/`** — 從消費端結構移除

### Documentation

- **README.md** — 補齊 `git-conventions.mdc`、3 個遺漏模板；移除 `extensions/`、`presets/`（不存在）���Validate 標為 optional；git clone URL 標註內部；skills 列表改指向 `skill-registry.yml`
- **`docs/architecture.md`** — 全面更新為 `templates/` 路徑
- **`docs/extension-api-reference.md`** — `dist/` → `templates/`

---

## [0.7.0] - 2026-04-03

### Architecture

- **`dist/` → `templates/`** — 分發源目錄統一為 `templates/`，包含 commands/rules/skills/agents/hooks 及 spec 模板
- **`templates/hooks/`** — 新增 hooks 分發層，派發至消費端 `hooks/`（專案根目錄）
  - `pre-command-foundation.sh`：lifecycle 指令前驗證 context.md 完整性
  - `post-edit-check.sh`：檔案編輯後自動 TypeScript type-check + ESLint
  - `settings.json`：Claude Code hook 配置
- **Foundation check → hook** — align/plan/execute/review 四指令的 foundation 檢查 boilerplate 移除，改由 pre-command hook 統一處理
- **Memory 瘦身** — `progress.md`、`milestone.md` 廢除；`context.md` 為唯一溫層（§ Principles + § Current）；`principles.md` 降為冷層（僅 init/review 讀取）

### Commands

- **`speckit.validate`** — 新增深度驗證指令（安全、架構、程式碼品質、設計合規、BDD 產出）
- **`speckit.review`** — 精簡為 AC 覆蓋 + 就緒關卡；深度驗證移至 validate；新增分支防呆（block main/master）
- **`speckit.execute`** — VERIFY skip 需輸入 `SKIP` 確認，action 標記 `unverified`
- **`speckit.plan`** — BDD 移至 review；plan 改用 Acceptance Criteria（非 Gherkin）
- **`speckit.init`** — Docker CLI 偵測（`command -v docker`）；Package Manager 嚴格優先序（pnpm→yarn→bun→packageManager→npm）
- **`speckit.skills` / `speckit.sync`** — 從 command 轉為 bash 腳本（`speckit-skills.sh` / `speckit-sync.sh`）

### Rules

- **`speckit-rules.mdc`** — 200 → 78 行；操作意涵 → `references/principles-detail.md`；REFLECT 協議 → `references/reflect-protocol.md`；簡化流程 → `references/simplified-flow.md`
- **`clean-code.mdc` / `codequality.mdc`** — NEVER→ALWAYS→PREFER→AVOID 排序 + 量化約束（≤20 行/函式、≤4 參數、≤7 props）
- **Skills index** — `speckit-rules.mdc` 末尾新增可用 Skills 索引（延遲載入）

### Skills & Agents

- **Agent 精簡** — designer/architect/frontend/code-auditor/kubernetes 五個 agent 移除，僅保留 `speckit_helper`
- **Skill 清理** — 移除 19 個不使用或重複的 skills；新增 `playwright-recording` + `playwright-streaming`
- **skill-registry.yml** — 移除空分類（documents/mobile/frontend_react/devops/frontend_svelte）

### Scripts

- **`speckit-sync.sh`** — `dist/` → `templates/` 路徑遷移；`sync_templates()` 僅同步頂層 spec 模板；新增 `sync_hooks()`
- **`speckit-skills.sh`** — 新增 Skills 管理腳本（list/add/remove/detect）
- **`speckit-sync.sh` bug fixes** — chmod +x 腳本權限；credentials prompt for private repos；首次安裝只同步 Core skills

### Removed

- `CLAUDE.md` — 不再需要（framework 自帶 rules）
- `dist/` — 重命名為 `templates/`
- `.specify/memory/progress.md` / `milestone.md` / `README.md` — 合併至 context.md § Current
- `temp/speckit.skills.md` / `temp/speckit.sync.md` — 轉為 bash 腳本
