---
description: Project initialization — create or audit context.md + principles.md in one command.
handoffs:
  - label: Start alignment
    agent: speckit.align
    prompt: Foundation is ready, begin aligning the first feature...
    send: true
---

## User Input

```text
$ARGUMENTS
```

Before proceeding, you **must** consider user input (if non-empty).

## Overview

`/speckit.init` — one-command initialization for two Foundation files.

- **New project**: auto-detect repo info, guide input, create Foundation
- **Existing project**: check completeness, suggest optimizations, report status

### Mode Detection

| State | Behavior |
|-------|----------|
| Both files missing or all placeholders | **Init Mode**: create from scratch |
| Some placeholders remain | **Complete Mode**: fill gaps |
| Both files complete (no placeholders) | **Audit Mode**: analyze and suggest optimizations |

---

## Phase 1: Detect & Report

Run `skills/speckit/scripts/bash/check-foundation.sh`, parse JSON, report:

```
Foundation Status:
- context.md: [complete/partial/template/missing]
- principles.md: [complete/partial/template/missing]
```

**Route to mode**:
- Both `missing` or `template` → **Init Mode**
- Any `partial` → **Complete Mode**
- Both `complete` → **Audit Mode**

---

## Init Mode (New Project)

### Step 1: Gather Project Context

1. **Parse user input**: extract info already provided in `$ARGUMENTS`

2. **Auto-detect from repository**:
   - `README.md` → project name, description
   - `package.json` / `go.mod` / `Cargo.toml` / `pyproject.toml` → language, framework, dependencies
   - `tsconfig.json` / `.eslintrc` → configuration
   - `.github/` → workflows
   - `docker-compose.yml` → infrastructure
   - `docs/llms.txt` → available external references
   - Existing source code → architecture patterns

3. **If required fields are missing**: infer from context; only ask the user when no reasonable default exists. **Max 5 questions**.

4. **Copy template and populate `.specify/memory/context.md`**:
   - If file is missing or still a template: copy from `templates/context-template.md`
   - Fill these sections:
   - Project Identity (name, description, repo URL)
   - Core Behaviors (observable, testable)
   - Target Users (personas, roles, goals)
   - Business Goals (metrics, targets, priorities)
   - Technical Context (language, framework, test stack)
   - Architecture Patterns (structure, naming conventions)
   - Integration Points (external systems, protocols)
   - Design References (optional: design system, Figma URL)

### Step 2: Define Principles

1. **Derive principles from project context**:
   - Technical constraints → MUST/MUST NOT statements
   - Architecture patterns → Invariants
   - Security/compliance requirements → Behavior boundaries

2. **Structure the principles**:
   - Core Principles (MUST / MUST NOT / Rationale / Verification)
   - Behavior Boundaries table (ID / Forbidden Behavior / Reason / Enforcement)
   - System Invariants (INV-001, INV-002, ...)
   - Governance rules

3. **Copy template and write `.specify/memory/principles.md`**:
   - If file is missing or still a template: copy from `templates/principles-template.md`
   - Fill in derived principles

4. **Append summary sections to `context.md`**:

   ```markdown
   ## Principles (Quick Reference)

   | # | Type | Rule |
   |---|------|------|
   | 1 | MUST | [extracted from principles.md] |
   | ... | ... | ... |

   ## Current

   - **Foundation**: complete
   - **Phase**: init
   - **Last**: init completed
   - **Next**: /speckit.align
   ```

   - Principles section: extract MUST/MUST NOT items from principles.md (max 10, table format)
   - Current section: 4-line status tracker, replaces progress.md
   - **context.md is the sole warm layer**: subsequent commands only read context.md; principles.md is the cold layer (read only during init/review deep checks)

### Step 2.5: Smart Skills Selection

Execute per `speckit/references/skills-selection` (Phases A-D: auto-detect → confirm → display → write manifest).

> Init Mode only. Complete/Audit Mode skip this step.

### Step 3: Environment Setup

Set up the project environment based on Technical Context:

1. **Determine dependency file** by primary language (package.json, requirements.txt, etc.)
2. **Add baseline dependencies** per declared tech stack (framework, testing)
3. **Create minimal skeleton** (src/, tests/) if directories don't exist
4. **Create `.gitignore`** if it doesn't exist
5. **Package manager detection & install** (strict priority):
   - `pnpm-lock.yaml` → `pnpm install`
   - `yarn.lock` → `yarn install`
   - `bun.lockb` → `bun install`
   - `package.json` `packageManager` field → corresponding tool
   - None of the above → `npm install`
   - **Skip if**: `node_modules/` exists and all dependencies are installed; also skip bootstrap entirely if the dependency file already exists and contains declared dependencies
   - Failure is non-blocking; record as TODO
6. **Verify test runner** — confirm the test toolchain is available

---

## Complete Mode (Fill Gaps)

1. **Identify remaining placeholders** in both files
2. **Auto-detect values from repo context** where possible
3. **Ask the user** when inference fails (max 3 questions)
4. **Fill in** remaining placeholders
5. **Verify** both files are complete

---

## Audit Mode (Analyze & Optimize)

When both files are complete, run a health analysis:

### context.md Analysis

- **Staleness detection**: does the tech stack description match the actual package.json/go.mod?
- **Gap detection**: are there new integration points not yet documented?
- **Architecture consistency**: does Code Organization reflect the current directory structure?

### principles.md Analysis

- **Coverage**: does every MUST NOT have a corresponding enforcement method?
- **Testability**: does every principle have verification criteria?
- **Invariant completeness**: are there obvious missing invariants?
- **Version consistency**: is the Version field correct?

### Optimization Suggestions

Produce a structured report:
```markdown
## Foundation Audit Report

### context.md
- Status: complete
- Findings:
  - [SUGGEST] Technical Context framework version may need update (package.json shows v5.x, context records v4.x)
  - [OK] Architecture Patterns match directory structure

### principles.md
- Status: complete
- Findings:
  - [SUGGEST] BB-003 missing Enforcement field
  - [SUGGEST] Consider adding INV-004: [suggestion based on code patterns]
  - [OK] All MUST NOT entries have corresponding verification
```

---

## Final Steps

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: init
- **Last**: init — [mode] completed
- **Next**: /speckit.align
- Include: Foundation status, auto-detected values, bootstrap result, remaining placeholders, optimization suggestions (Audit Mode)

## Behavior Rules

> Common rules: see `speckit/references/command-shared`.

- Max 5 questions (Init) / 3 questions (Complete)
- Bootstrap is incremental — never overwrite existing dependency files
- Bootstrap failure is non-blocking — warn, log, continue
- Snapshot before update — if principles.md was complete and will be modified, create snapshot first
