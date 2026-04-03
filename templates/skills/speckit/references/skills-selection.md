---
name: speckit/references/skills-selection
description: Smart Skills selection flow for /speckit.init — auto-detect, confirm, write manifest. Init Mode only.
---

# Smart Skills Selection

Init Mode only. Post-init management: `/speckit.skills`.

## Phase A: Auto-detect (zero interaction)

Read `skill-registry.yml`, scan project against each category's `detect` rules:

- `package.json` → match `detect.deps` (react, vue, svelte, next, tailwindcss, playwright...)
- `go.mod` / `Cargo.toml` / `pyproject.toml` → match `detect.files`
- `tsconfig.json` → enable `frontend_typescript`
- `command -v docker` + Dockerfile/docker-compose.yml → record containerized env
- `.pen` files / README contains `figma.com` → enable `design`

Auto-check all matching categories.

## Phase B: Guided Confirmation (max 3 questions via AskQuestion)

**Q1**: Project type (show auto-detect results) → `[A] Correct` / `[B] Needs adjustment`

**Q2**: Design tool integration (only if not auto-detected) → `[A] Figma` / `[B] Pencil (.pen)` / `[C] Design from scratch` / `[D] None`

**Q3**: Additional capabilities (multi-select, undetected only) → `[A] DevOps/K8s` / `[B] Office docs` / `[C] Browser automation` / `[D] AI Agent dev` / `[E] None`

## Phase C: Display & Confirm

```
Skills Selection Result:
Core (N): speckit, git-commit, ...
[Category] (N): ...
Agents (N): ...
Total: X skills + Y agents | Confirm? [Y/n]
```

## Phase D: Write Manifest

Generate `.specify/config/skills.yml`:

```yaml
version: 1
auto_detected:
  frontend_web: true
  frontend_react: true
user_selected:
  design: true
  devops: false
selected_skills:
  - speckit
  - git-commit
  # ... full list
selected_agents:
  - speckit
  - designer
```
