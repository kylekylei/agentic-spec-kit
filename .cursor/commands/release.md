---
description: Publish a new version - bump CHANGELOG.md, update config version, commit, and push to remote
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty). The user may specify a version number (e.g., "0.3.0") or a bump type (e.g., "patch", "minor", "major").

## Purpose

Automate the complete version release workflow:
1. Extract changes from `[Unreleased]` section in CHANGELOG.md
2. Determine next version number (with user confirmation)
3. Update CHANGELOG.md with new version + today's date
4. Update `.teammate/config/teammate.yml` version field
5. Commit changes with `chore(release): vX.Y.Z` message
6. Push to remote

## Execution Steps

### Step 1: Read Current State

Run in parallel:
1. Read `CHANGELOG.md` to extract:
   - Current version (latest `## [X.Y.Z]` entry)
   - Content in `## [Unreleased]` section
2. Read `.teammate/config/teammate.yml` to get current `version` field

### Step 2: Determine Next Version

Based on current version (e.g., `0.2.0`), suggest next version options:

- **patch** (0.2.1) — Bug fixes, small tweaks
- **minor** (0.3.0) — New features, non-breaking changes
- **major** (1.0.0) — Breaking changes, major milestones

If `$ARGUMENTS` contains a version number (e.g., "0.3.0") or bump type (e.g., "minor"), use it as default.

Use `AskUserQuestion` to confirm:
- [A] patch (X.Y.Z+1)
- [B] minor (X.Y+1.0)
- [C] major (X+1.0.0)
- [D] Custom version (user specifies)

### Step 3: Validate Unreleased Changes

Check if `[Unreleased]` section has actual content:
- If all subsections are "(無)" or empty, **WARN** the user and ask if they want to proceed
- Suggest user should add changes to Unreleased first before releasing

### Step 4: Update CHANGELOG.md

Perform the following edits:

1. **Create new version section** — Insert below `[Unreleased]`:
   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD

   [Content from Unreleased section]
   ```
   Use today's date in ISO format (YYYY-MM-DD).

2. **Reset Unreleased section** — Replace with:
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

### Step 5: Update teammate.yml

Edit `.teammate/config/teammate.yml`:
- Change `version: "OLD_VERSION"` to `version: "NEW_VERSION"`

### Step 6: Commit Changes

Execute the following **sequentially**:

1. Stage files:
   ```bash
   git add CHANGELOG.md .teammate/config/teammate.yml
   ```

2. Commit with release message:
   ```bash
   git commit -m "$(cat <<'EOF'
   chore(release): vX.Y.Z

   - Update CHANGELOG.md with version X.Y.Z
   - Bump framework version in teammate.yml

   Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
   EOF
   )"
   ```

3. Verify commit:
   ```bash
   git log -1 --oneline
   ```

### Step 7: Push to Remote

Before pushing, check:
1. Current branch name (via `git branch --show-current`)
2. Remote tracking status (via `git status`)

Execute push:
```bash
git push origin <branch-name>
```

If push fails (e.g., no remote, permission denied), report the error and suggest next steps.

### Step 8: Report Success

Output summary:

```markdown
## ✅ Release vX.Y.Z Published

**Version**: X.Y.Z
**Date**: YYYY-MM-DD
**Commit**: [short hash]
**Branch**: [branch name]
**Remote**: Pushed successfully

### Next Steps
- Create a GitHub Release (if needed): `gh release create vX.Y.Z`
- Tag the release locally: `git tag vX.Y.Z`
```

## Key Rules

- **Never skip user confirmation** — Always confirm version bump before proceeding
- **Atomic commit** — Only commit CHANGELOG.md + teammate.yml together
- **No force push** — Never use `--force` or `--force-with-lease`
- **Validate state** — Check git status is clean before starting (warn if uncommitted changes exist)
- **Abort on error** — If any step fails, stop and report (don't proceed to push)
- **Date format** — Always use ISO date (YYYY-MM-DD) for consistency

## Edge Cases

1. **Dirty working tree** — Warn user and suggest committing/stashing first
2. **No unreleased changes** — Warn but allow proceeding (empty release)
3. **Custom version** — Validate semantic version format (X.Y.Z)
4. **No remote configured** — Skip push step and notify user
5. **Push rejected** — Suggest `git pull --rebase` before retrying

## Output Mode

Use **Lean Mode** — concise status updates, only expand on errors or warnings.
