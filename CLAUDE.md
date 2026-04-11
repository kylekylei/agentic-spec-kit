# Speckit — Claude Code Reference

Speckit 透過 `speckit-sync.sh` 將 `templates/` 同步至消費端 `.claude/` 目錄。

## 框架間契約（Contracts）

跨系統邊界主要交付物一律採 JSON（框架間交付格式原則）。

| 上游 | 契約路徑 | 消費指令 |
|------|---------|---------|
| spec-ops | `specs/*/reviews/*-spec-contract-v*.json` | `/speckit.init`, `/speckit.validate`, `/speckit.ship` |
| experience-kit | `contracts/*-experience-contract-v*.json` | `/speckit.init`, `/speckit.align` |

## Path Mapping

| `templates/` | `.claude/` |
|--------------|------------|
| `commands/` | `commands/` |
| `rules/` | `rules/` |
| `skills/` | `skills/` |
| `agents/` | `agents/` |
| `hooks/` | `hooks/`（專案根目錄） |

## Installation

```bash
./install.sh /path/to/project --platform claude
```

## Hooks

| 檔案 | 觸發時機 | 用途 |
|------|---------|------|
| `pre-command-foundation.sh` | PreToolUse (Bash) | 驗證 context.md 完整性 |
| `post-edit-check.sh` | PostToolUse (Write/Edit) | TypeScript type-check + ESLint |
| `settings.json` | — | Hook 配置 |
