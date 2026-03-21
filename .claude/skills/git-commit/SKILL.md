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

When asked to commit:

1. Run `git status` and `git diff --staged` (and `git diff` for unstaged) to understand all changes
2. Run `git log --oneline -5` to match the repository's existing style
3. Analyze changes — determine the appropriate type and scope
4. If changes span multiple unrelated concerns, suggest splitting commits
5. Draft a commit message following the format above
6. Stage files with `git add` (exclude secrets: `.env`, credentials, etc.)
7. Commit using HEREDOC format:
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <description>

   <body>

   <footer>
   EOF
   )"
   ```

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
