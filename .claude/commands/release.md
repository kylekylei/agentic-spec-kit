---
description: Publish a new version — move [Unreleased] to a versioned release, bump speckit.yml, commit, and push.
---

## User Input

```text
$ARGUMENTS
```

可指定版本號（如 `0.5.1`）或 bump 類型（`patch` / `minor` / `major`）。

## Execution Steps

### Step 1: Read Current State

平行執行：
1. 讀取 `CHANGELOG.md` — 取得最新版本號與 `[Unreleased]` 內容
2. 讀取 `.specify/config/speckit.yml` — 取得當前 `version` 欄位
3. 執行 `git status --short` — 確認工作目錄狀態

### Step 2: Validate

- **Unreleased 為空**（全為 `(無)`）→ 警告並詢問是否繼續
- **工作目錄有未提交變更** → 警告，建議先 `/commit` 再 release

### Step 3: Confirm Version

根據當前版本推算選項，使用 AskQuestion 確認：
- patch (X.Y.Z+1) — Bug fixes、小調整
- minor (X.Y+1.0) — 新功能、非破壞性變更
- major (X+1.0.0) — 破壞性變更、重大里程碑

若 `$ARGUMENTS` 已指定版本或 bump 類型，直接採用（仍需確認）。

### Step 4: Update CHANGELOG.md

1. 在 `[Unreleased]` 下方插入新版本區段：
   ```
   ## [X.Y.Z] - YYYY-MM-DD
   <[Unreleased] 的內容>
   ```
   日期使用今日 ISO 格式（YYYY-MM-DD）。

2. 重設 `[Unreleased]` 為空白模板：
   ```markdown
   ## [Unreleased]

   > 累積中的變更，尚未歸入版本號。下次發行時移到具體版本區段。

   ### Added
   - (無)

   ### Changed
   - (無)

   ### Documentation
   - (無)
   ```

### Step 5: Update speckit.yml

將 `.specify/config/speckit.yml` 的 `version` 欄位改為新版本號。

### Step 6: Commit

僅 stage 兩個檔案：

```bash
git add CHANGELOG.md .specify/config/speckit.yml
```

使用暫存檔方式 commit（PowerShell 不支援 HEREDOC）：
1. 寫入 commit message 到暫存檔 `.git/RELEASE_MSG_temp`
2. `git commit -F ".git/RELEASE_MSG_temp"`
3. 確認 `git log -1 --oneline`

Commit message 格式：
```
chore(release): vX.Y.Z

- Update CHANGELOG.md with version X.Y.Z
- Bump framework version in speckit.yml

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

### Step 7: Push

```bash
git push origin <branch-name>
```

失敗時回報錯誤，不強制 push。

### Step 8: Report

```markdown
## ✅ Release vX.Y.Z Published

**Version**: X.Y.Z
**Date**: YYYY-MM-DD
**Commit**: [short hash]
**Branch**: [branch name]
**Remote**: Pushed successfully
```

## Key Rules

- **不跳過版本確認** — 永遠 AskQuestion 確認版本號
- **Atomic commit** — 只 commit CHANGELOG.md + speckit.yml，其他變更不納入
- **不 force push**
- **PowerShell 相容** — 使用暫存檔取代 HEREDOC（`git commit -F`）
