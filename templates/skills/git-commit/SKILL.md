---
name: git-commit
description: Generate Conventional Commits messages for git operations. Use when Claude needs to create a git commit, write a commit message, stage and commit changes, or when the user asks to commit code. Follows the Conventional Commits 1.0.0 specification with project-aware scope detection.
---

# Git Commit Skill

Generate standardized commit messages following [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

## Commit Message Format

```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Types

| Type | When to Use | SemVer |
|------|-------------|--------|
| `feat` | New feature or capability | MINOR |
| `fix` | Bug fix | PATCH |
| `docs` | Documentation only | - |
| `style` | Formatting, whitespace, semicolons (no logic change) | - |
| `refactor` | Code restructuring (no feature/fix) | - |
| `perf` | Performance improvement | - |
| `test` | Add or update tests | - |
| `build` | Build system, dependencies (pip, npm, etc.) | - |
| `ci` | CI/CD configuration | - |
| `chore` | Maintenance tasks, tooling, configs | - |
| `revert` | Revert a previous commit | - |

## Scope Detection

Infer scope from the changed files. Use the most specific relevant module name:

- Changes in `stock_agent/analyzers/chip/` → `scope: chip`
- Changes in `stock_agent/strategies/rule_engine.py` → `scope: rule-engine`
- Changes in `tests/` → `scope: tests`
- Changes in `.cursor/skills/` → `scope: skills`
- Changes spanning multiple modules → omit scope or use the primary module

## Rules

1. **Description**: Imperative mood, lowercase, no period at end, max 72 chars
   - Good: `feat(chip): add CASI threshold configuration`
   - Bad: `feat(chip): Added CASI threshold configuration.`

2. **Body**: Explain WHAT and WHY, not HOW. Wrap at 72 chars. Separate from description with blank line.

3. **Breaking changes**: Add `!` after type/scope AND include `BREAKING CHANGE:` footer
   ```
   feat(rule-engine)!: replace scoring system with weighted rules

   BREAKING CHANGE: RuleEngine.evaluate() now returns RuleResult instead of float
   ```

4. **Multi-concern commits**: If changes span unrelated concerns, suggest splitting into separate commits.

5. **Footer references**: Link issues when applicable
   ```
   fix(backtest): correct profit factor calculation

   Closes #42
   ```

## Workflow

When asked to commit, execute the following 7 steps:

### Step 1: Gather Context

Run the following commands **in parallel**:

1. `git status` — 查看所有未追蹤和已修改的檔案
2. `git diff --staged` + `git diff` — 查看暫存和未暫存的變更內容
3. `git log --oneline -5` — 參考最近的 commit 風格

### Step 2: Analyze Changes

1. 根據變更內容判斷 **type**（feat / fix / docs / refactor / chore 等）
2. 根據變更檔案路徑推斷 **scope**（依 Scope Detection 規則）
3. 如果使用者有提供描述，將其作為 commit 意圖的參考
4. 如果變更跨越多個不相關的 concern，**建議拆分為多次 commit**，使用 AskQuestion 詢問使用者

### Step 3: Draft Message

根據 Conventional Commits 格式撰寫 commit message：

- **description**：祈使語氣、小寫、不加句號、不超過 72 字元
- **body**（視需要）：說明 WHAT 和 WHY，每行不超過 72 字元
- **footer**（視需要）：Breaking Change、Issue 引用

### Step 4: Confirm with User

向使用者展示：
1. 將被 stage 的檔案清單
2. 草擬的 commit message

使用 AskQuestion 詢問：
- [A] 確認送出
- [B] 修改 commit message
- [C] 調整 stage 的檔案範圍
- [D] 取消

### Step 5: Execute

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

### Step 6: Report

輸出 commit 結果摘要：

```
Hash: [short hash]
Message: [commit message first line]
Files: [N files changed]
```

### Step 7: Key Rules

- **不跳過確認** — 除非使用者明確表示「直接 commit」或「auto」
- **不 commit 敏感檔案** — `.env`、credentials、API keys 等永遠排除，若偵測到則警告
- **不 push** — 只做 commit，不自動 push（除非使用者明確要求）
- **拆分建議** — 變更跨多個不相關 concern 時，建議拆分而非合併為一個大 commit

## Examples

Single-line (most common):
```
feat(notifier): add weekly summary report to Telegram
fix(twse): handle rate limit retry for 429 responses
docs: update CLAUDE.md with new backtest commands
refactor(pool-manager): extract filtering logic into separate method
test(rule-engine): add edge cases for stop-loss calculation
build: upgrade yfinance to 0.2.36
chore: remove deprecated config entries
```

With body:
```
fix(backtest): correct win rate calculation for partial fills

Previously, partial fills were counted as full losses. Now the P&L
is calculated proportionally based on the filled quantity.
```

With breaking change:
```
feat(rule-engine)!: migrate from dict-based to dataclass signals

Signal objects now use SignalResult dataclass instead of raw dicts.
All consumers of RuleEngine.evaluate() must update their code.

BREAKING CHANGE: evaluate() returns SignalResult instead of dict
```
