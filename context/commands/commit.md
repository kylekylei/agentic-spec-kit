---
description: Stage and commit changes using Conventional Commits format. Analyzes diffs, detects scope, drafts message, and executes git commit.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Skill

Read and follow the git-commit skill at `.cursor/skills/git-commit/SKILL.md` **before** proceeding.

## Execution Steps

### Step 1: Load Skill

Read `.cursor/skills/git-commit/SKILL.md` and internalize the Conventional Commits rules, type table, scope detection, and workflow.

### Step 2: Gather Context

Run the following commands **in parallel**:

1. `git status` — 查看所有未追蹤和已修改的檔案
2. `git diff --staged` + `git diff` — 查看暫存和未暫存的變更內容
3. `git log --oneline -5` — 參考最近的 commit 風格

### Step 3: Analyze Changes

1. 根據變更內容判斷 **type**（feat / fix / docs / refactor / chore 等）
2. 根據變更檔案路徑推斷 **scope**（依 skill 的 Scope Detection 規則）
3. 如果 `$ARGUMENTS` 有描述，將其作為 commit 意圖的參考
4. 如果變更跨越多個不相關的 concern，**建議拆分為多次 commit**，使用 AskQuestion 詢問使用者

### Step 4: Draft Message

根據 Conventional Commits 格式撰寫 commit message：

- **description**：祈使語氣、小寫、不加句號、不超過 72 字元
- **body**（視需要）：說明 WHAT 和 WHY，每行不超過 72 字元
- **footer**（視需要）：Breaking Change、Issue 引用

### Step 5: Confirm with User

向使用者展示：
1. 將被 stage 的檔案清單
2. 草擬的 commit message

使用 AskQuestion 詢問：
- [A] 確認送出
- [B] 修改 commit message
- [C] 調整 stage 的檔案範圍
- [D] 取消

### Step 6: Execute

使用者確認後：

1. 排除敏感檔案（`.env`、credentials、secrets）
2. `git add` stage 相關檔案
3. 使用 HEREDOC 格式執行 commit：

```bash
git commit -m "$(cat <<'EOF'
<type>(<scope>): <description>

<body>

<footer>
EOF
)"
```

4. 執行 `git status` 確認 commit 成功

### Step 7: Report

輸出 commit 結果摘要：

```markdown
## ✅ Commit 完成

**Hash**: [short hash]
**Message**: [commit message first line]
**Files**: [N files changed]
```

## Key Rules

- **遵循 Conventional Commits 1.0.0** — 嚴格按照 skill 定義的格式
- **不跳過確認** — 除非使用者在 `$ARGUMENTS` 明確表示「直接 commit」或「auto」
- **不 commit 敏感檔案** — `.env`、credentials、API keys 等永遠排除，若偵測到則警告
- **不 push** — 只做 commit，不自動 push（除非使用者明確要求）
- **拆分建議** — 變更跨多個不相關 concern 時，建議拆分而非合併為一個大 commit
