---
description: Initialize project context by collecting project information and filling project-context.md.
handoffs:
  - label: Define Principles
    agent: teammate.principles
    prompt: "Project context is ready. Let's define the non-negotiable principles and boundaries..."
  - label: Start Alignment
    agent: teammate.align
    prompt: "Foundation is ready. Let's align on the first feature..."
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

You are initializing the project context for the Teammate workflow. This is the **first step** in any new project — before alignment, before principles, before any work begins.

### Purpose

The kickoff command collects project information and fills **one file**:

- **`.teammate/memory/project-context.md`** — Who we are, what we build, who it's for, how it's built

This file is the single source of truth for project-level context. Keep it simple — just record the facts.

### Execution Flow

#### Phase 1: Load & Detect

1. **Read `.teammate/memory/project-context.md`**

2. **Detect placeholder tokens**:
   - Scan for patterns matching `[ALL_CAPS_IDENTIFIER]` (e.g. `[PROJECT_NAME]`, `[BEHAVIOR_1]`)
   - Classify file status:
     - **Template**: All placeholders remain (fresh file)
     - **Partial**: Some placeholders filled, some remain
     - **Complete**: No placeholders detected

3. **Report current status** to the user before proceeding.

#### Phase 2: Collect Information

1. **Parse user input** from `$ARGUMENTS`:
   - If provided, extract all available information
   - If empty, guide the user through an interactive collection

2. **Auto-detect from repository** to supplement user input:
   - `README.md` → Project name, description
   - `package.json` / `go.mod` / `Cargo.toml` / `pyproject.toml` → Language, framework, dependencies
   - `tsconfig.json` / `.eslintrc` → TypeScript/JS configuration
   - `.github/` → Repository workflows
   - `docker-compose.yml` / `Dockerfile` → Infrastructure hints
   - Existing source code structure → Architecture patterns

3. **For missing required fields**:
   - Make informed guesses based on repository context
   - Only ask the user if:
     - No reasonable default exists
     - Multiple valid interpretations exist
   - **LIMIT**: Maximum 5 questions to the user

#### Phase 3: Fill project-context.md

Fill in the following sections of `.teammate/memory/project-context.md`:

- **Project Identity**: Name, description, repository URL
- **Core Behaviors**: Observable, testable product behaviors
- **Target Users**: Personas, roles, goals
- **Business Goals**: Metrics, targets, priorities
- **Technical Context**: Language, framework, runtime, testing stack
- **Architecture Patterns**: System architecture, code organization, naming conventions
- **Integration Points**: External systems, protocols, contracts
- **Design References** (optional): Design system name, Figma link, Storybook link
  - Only fill if user provides this information
  - Feature-level Figma page links belong in `/teammate.tasks`, not here

#### Phase 4: Validation & Report

1. **Validate `project-context.md`**:
   - Scan for remaining placeholder tokens
   - If any remain → Warn user with specific missing fields
   - Check that essential fields are filled:
     - Project Name (not `[PROJECT_NAME]`)
     - At least one Core Behavior
     - At least one Target User
     - Primary Language defined

2. **Report Kickoff Summary**:

   ```
   ## Kickoff Summary
   
   ### project-context.md
   - [N] fields filled, [M] auto-detected
   
   ### Auto-detected Values
   - Language: [detected from package.json/go.mod/etc.]
   - Framework: [detected]
   - ...
   
   ### Remaining Placeholders
   - [List any unfilled fields, if any]
   
   ### Recommended Next Steps
   1. Run `/teammate.principles` to define non-negotiable boundaries
   2. Run `/teammate.align` to start working on the first feature
   ```

3. **Update Active Context**:
   Update `.teammate/memory/active-context.md`:
   - Mark `kickoff` as complete
   - Note any remaining placeholders (if any)
   - Set next action as `teammate.principles`

## What Does NOT Belong Here

- **Agent behavior / AI guardrails** → Define in `/teammate.principles` (optional)
- **Feature-level Figma page links** → Provide during `/teammate.tasks` for each feature
- **Design tokens / components** → These are implementation details, not project context

## Behavior Rules

- **Only fill `project-context.md`** — one file, keep it simple
- **Auto-detect first, ask second** — minimize user effort
- **Never fabricate information** — if unsure, mark as `TODO(<FIELD>): needs clarification`
- **Idempotent** — running kickoff again preserves existing values, only fills gaps
- **Maximum 5 questions** — respect the user's time
