# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is an AI collaboration framework distributed to consumer projects. This repo is the **Hub** — the source of truth. Consumer projects never edit framework files directly; changes flow Hub → consumer via sync.

## Key Commands

### Install into a consumer project
```bash
./install.sh /path/to/project          # auto-detect IDE (Cursor / Claude Code / Antigravity)
./install.sh /path/to/project --dry-run
./install.sh /path/to/project --platform claude
./install.sh /path/to/project --self-update   # pull latest Hub before syncing
```

### Sync Hub changes to a consumer project
```bash
SPECKIT_HOME=$(pwd) bash dist/skills/speckit/scripts/bash/speckit-sync.sh /path/to/project
SPECKIT_HOME=$(pwd) bash dist/skills/speckit/scripts/bash/speckit-sync.sh /path/to/project --dry-run
SPECKIT_HOME=$(pwd) bash dist/skills/speckit/scripts/bash/speckit-sync.sh /path/to/project --check
```

### Legacy dev tool (symlinks only, not for distribution)
```bash
bash scripts/link-project.sh /path/to/project
```

## Architecture

### `dist/` → IDE mapping

`dist/` is the Hub source. `speckit-sync.sh` maps it to each IDE's directory convention:

| `dist/` | Cursor | Claude Code | Antigravity |
|---------|--------|-------------|-------------|
| `commands/` | `.cursor/commands/` | `.claude/commands/` | `.agent/workflows/` |
| `rules/` | `.cursor/rules/` | `.claude/rules/` | `.agent/rules/` |
| `skills/` | `.cursor/skills/` | `.claude/skills/` | `.agent/skills/` |
| `agents/` | `.cursor/agents/` | `.claude/agents/` | `.agent/personas/` |

**Critical**: Never use `dist/` as a path prefix inside any file under `dist/`. Consumer projects have no `dist/` directory. Use IDE-relative paths: `skills/speckit/scripts/bash/` (without IDE prefix — the AI resolves `.cursor/` or `.claude/` at runtime).

### Layer responsibilities

| Layer | Location | Purpose |
|-------|----------|---------|
| **Commands** | `dist/commands/speckit.*.md` | `speckit.*` lifecycle SOPs — called explicitly |
| **Rules** | `dist/rules/*.mdc` | Always-on constraints and principles |
| **Skills** | `dist/skills/*/SKILL.md` | Domain knowledge, reusable capabilities (stateless) |
| **Agents** | `dist/agents/*.md` | Personas — route intent, compose Skills |

Rules: only `speckit.*` lifecycle flows become Commands. Domain logic → Skill. Role/persona → Agent. Agents don't implement logic; they declare Skills and route intent.

### Bash scripts

Scripts live in `dist/skills/speckit/scripts/bash/`. They are synced to consumer projects under the IDE skills directory. Commands reference them as `skills/speckit/scripts/bash/<script>.sh` (IDE prefix resolved at runtime).

Key scripts:
- `check-foundation.sh` — validates `context.md` + `principles.md` completeness, outputs JSON
- `check-prerequisites.sh` — verifies spec prerequisites, returns `SPEC_DIR` and doc paths
- `create-new-spec.sh` — creates spec directory with correct numbering
- `speckit-sync.sh` — the main sync engine (also used by `install.sh`)

## Definition of Done for Framework Changes

Any modification to commands, rules, skills, agents, templates, or scripts is **not complete** until:

1. `README.md` updated
2. `CHANGELOG.md` `[Unreleased]` section updated — mandatory for any change to `dist/commands/speckit.*.md` or `dist/rules/`
3. Consumer projects notified (run `/speckit.sync` or re-run `install.sh`)

`PLAYBOOK.md` (gitignored) tracks lessons learned — append-only, never edit existing entries.

## skill-registry.yml

`dist/skills/skill-registry.yml` is the single source of truth for all Skills and Agents. Any new Skill or Agent must be registered here with detection rules and category.
