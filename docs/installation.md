# Installation

## 支援平台

| 平台 | IDE 目錄 | 偵測條件 |
|------|---------|---------|
| Cursor | `.cursor/` | 目錄存在 |
| Claude Code | `.claude/` | 目錄或 `CLAUDE.md` 存在 |
| Antigravity | `.agent/` | 目錄存在 |

## 安裝方式

### 方式一：install.sh（推薦）

```bash
git clone <source-url> ~/.speckit
~/.speckit/install.sh /path/to/project
```

Options:
- `--dry-run`：預覽不寫入
- `--platform cursor|claude|antigravity|all`：指定平台
- `--self-update`：先拉最新 Source 再同步

### 方式二：直接同步

```bash
SPECKIT_HOME=/path/to/source bash /path/to/source/scripts/bash/speckit-sync.sh .
```

## 首次安裝行為

- 若無 `.specify/config/skills.yml`：僅安裝 Core skills（6 個）
- 執行 `/speckit.init` 後自動選配完整 skills
- 後續使用 `/speckit.skills` 管理

## 更新

```bash
~/.speckit/install.sh /path/to/project --self-update
```

## 私有 Source

若 Source 為私有 Git repo，同步時會提示 Git 憑證（Username + Token）。

## Troubleshooting

| 問題 | 解法 |
|------|------|
| `Sync script not found` | 確認從 Source 根目錄執行 `install.sh` |
| 腳本無執行權限 | `chmod +x scripts/bash/*.sh` |
| Clone 失敗 | 確認 Git 憑證、網路設定 |
