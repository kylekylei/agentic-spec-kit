---
description: Generate Gherkin scenarios, technical plan with Screenplay Pattern, and atomic actions — all in one pass. Produces .feature + tasks.md + actions.md.
handoffs: 
  - label: Execute Actions
    agent: teammate.execute
    prompt: Start the Red-Green Loop implementation
    send: true
  - label: Review Coverage
    agent: teammate.review
    prompt: Run a behavioral coverage analysis before executing
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: Transform the aligned spec and examples into a complete execution plan — **Gherkin scenarios** (WHAT to verify), **technical tasks** (HOW to build), and **atomic actions** (STEPS to execute) — in one continuous pass.

### Mode Detection

Parse `$ARGUMENTS` for the keyword **`update`**:

- If `$ARGUMENTS` contains "update" → **Update Mode** (preserve existing work, snapshot before changes, mark with `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`)
- Otherwise → **Create Mode** (default)

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Update Mode

When running with `update`, the command preserves existing work:

1. **Pre-Update Snapshot**: Copy existing `tasks.md`, `actions.md`, `scenarios/*.feature` to `.teammate/snapshots/`
2. **Ask user**: "What changed and why?" (one line)
3. **Diff-Aware Processing**: Compare baseline against current spec/examples
4. **Mark changes**: `[UNCHANGED]`, `[NEW]`, `[REVISED]`, `[REMOVED]`
5. **Sync Contracts** (if `contracts/ui/` exists): Update stale entries
6. **Impact Report**: Count unchanged/new/revised/removed items
7. **Never discard completed work** — removed items are commented out, not deleted

---

## Stage 1: Scenario Generation

> 產出：`FEATURE_DIR/scenarios/*.feature` + `teammate.refs.yaml`

### Setup

1. Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root. Parse JSON for `FEATURE_DIR`, `FEATURE_SPEC`.

2. **Load Context**:

   Required:
   - `FEATURE_DIR/spec.md` - User stories and requirements
   - `FEATURE_DIR/example-mapping.md` - Rules and examples
   - `.teammate/memory/principles.md` - Non-negotiable boundaries

   Optional:
   - `.teammate/templates/feature-template.feature` - Gherkin template
   - `FEATURE_DIR/contracts/ui/design-principles.md` - UX 設計原則

3. **Create Features Directory**: `mkdir -p FEATURE_DIR/scenarios`

### UX Conflict Scan (if `design-principles.md` exists)

在產生 scenarios 之前，強制執行設計原則衝突分析：

1. **設計原則 vs 核心原則交叉比對**: API 可行性、SSE 欄位存在性、是否需新增後端 endpoint
2. **互動元素可行性檢查**: 每個 UI action 需要的後端能力是否存在
3. **參考設計語意差異**: 外部參考產品的操作語意 vs 本專案操作語意
4. **Conflict Report**: 有 CONFLICT 或 SEMANTIC_GAP 時暫停讓使用者決策

### Scenario Generation

For each User Story (in priority order):

1. **Generate `.feature` file** with proper header, Background, and tagged Scenarios
2. **Map Example Mapping** rules → scenarios, examples → Given/When/Then
3. **Add Principles Boundary Scenarios** (`@principles @boundary`)
4. **Consolidate data-driven scenarios** using Scenario Outline where applicable
5. **Write** to `FEATURE_DIR/scenarios/[story-slug].feature`

### Context Anchors

Create/update `FEATURE_DIR/teammate.refs.yaml` with feature metadata, behavior references, and dependencies.

### Coverage Validation

| Metric | Count | Status |
|--------|-------|--------|
| User Stories | [N] | |
| Rules from Example Mapping | [N] | |
| Scenarios Generated | [N] | |
| Happy Path Coverage | [%] | |
| Negative Path Coverage | [%] | |
| Principles Boundaries | [N] | |

Requirements: Every rule → at least one scenario. Every P1 story → happy path + negative. Every principles boundary → a scenario.

### Gherkin Quality Check

- Each scenario is independent (can run in isolation)
- Steps are declarative (WHAT, not HOW)
- No implementation details in steps
- Tags follow convention (@P1/@P2/@P3, @happy-path, etc.)

---

## Stage 2: Technical Planning

> 產出：`FEATURE_DIR/screenplay.md` + `FEATURE_DIR/tasks.md` + `FEATURE_DIR/contracts/`

### Load Additional Context

Optional:
- `docs/llms.txt` → Check for relevant external API/SDK references
- `FEATURE_DIR/example-mapping.md`

### Screenplay Pattern Extraction

From the `.feature` files, extract the Screenplay model:

1. **Actors Discovery**: Identify actors from scenarios, define roles, goals, abilities
2. **Abilities Definition**: Group by interaction type (BrowseTheWeb, CallAnApi, QueryDatabase, etc.)
3. **Tasks Extraction**: Map scenarios to high-level tasks with preconditions, steps, postconditions

Write to `FEATURE_DIR/screenplay.md`.

### Test Infrastructure Check (Phase 0)

1. **檢查既有測試框架**: 掃描 `package.json` (vitest/jest/playwright), `pytest.ini`, `go.mod` 等
2. **若不存在**: 在 tasks.md 新增 Phase 0 必要 IMP（測試框架設定、測試目錄、mock setup）
3. **若已存在**: 記錄在 Technical Context 中

### Technical Planning

1. **Technical Context**: Language/Version, Dependencies, Storage, Testing framework, Constraints
2. **Principles Check**: Map each principle to technical decisions. *GATE: Must pass*
3. **Project Structure**: Source structure with file markers:
   - `[NEW]` — New file to create
   - `[ENHANCE]` — Existing file with functional changes
   - `[INTEGRATE]` — Existing file that must import/mount a [NEW] component (pure wiring)

### Integration Impact Analysis

For every `[NEW]` component, identify its **consumer** (existing file that must import/mount it):
- Every `[NEW]` UI component (not a child of another [NEW]) MUST have at least one `[INTEGRATE]` consumer
- Common integration points: `+layout.svelte` (global), `+page.svelte` (route-specific), parent components

### UI Interactive State Machine (if UI involved)

For each UI component with interactive elements:

1. **列舉所有互動元素**
2. **產出狀態機表格**: 元素 / 觸發條件 / 狀態 / 行為
3. **驗證**: 每個互動元素 MUST 有 enabled + disabled 狀態；每個 disabled MUST 說明原因

### Design Artifacts

Generate as needed:
- `contracts/api/` — OpenAPI specs
- `contracts/ui/` — Component specs (with Figma page link if available)
- `contracts/ai/` — Prompt contracts
- `data-model.md` — Entities

### Research & Decisions

If NEEDS CLARIFICATION items exist: Generate research tasks, consolidate in `research.md`.

Write to `FEATURE_DIR/tasks.md` using `.teammate/templates/task-template.md`.

---

## Stage 3: Action Breakdown

> 產出：`FEATURE_DIR/actions.md`

### Extract Scenario Tags

Parse all `.feature` files to build tag inventory:

| Tag | Scenario | Priority | Type |
|-----|----------|----------|------|
| @us1-login-success | User successfully logs in | @P1 | @happy-path |

### Generate Actions by User Story

For each user story (in priority order):

#### Action Format

Every action MUST follow this format:
```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

Components:
- `[ActionID]`: Sequential (S001, S002, S003...)
- `[Type]`: **REQUIRED** — `[LOGIC]`, `[UI]`, or `[LOGIC+UI]`
- `[P]`: Parallel marker (optional)
- `[Story]`: User story marker (US1, US2...)
- `[Verifies: @tag]`: Links to scenario tag(s) — **REQUIRED**

#### RED/GREEN Forced Split

`[LOGIC]` 和 `[LOGIC+UI]` 類型的 action，若涉及 util/store/service/model，MUST 拆為兩個連續 actions：

```markdown
- [ ] S010 [LOGIC] [US1] [Verifies: @us1-auth] RED: 建立 AuthService 測試 in tests/services/auth.test.ts
- [ ] S011 [LOGIC] [US1] [Verifies: @us1-auth] GREEN: 實作 AuthService in src/services/auth.ts
```

`[UI]` 類型不強制拆分（純 UI 無可自動化的 RED 測試）。

#### Integration Actions

For every `[INTEGRATE]` file in tasks.md, generate a mount/import action immediately after the component creation action.

### Phase Structure

- **Phase 0: Setup** — Project initialization, test infrastructure
- **Phase 1: Foundational** — Core infrastructure
- **Phase 2+: User Stories** — Story-specific actions (step definitions first, then implementation)
- **Phase N: Polish** — Cross-cutting concerns, documentation

### Traceability Matrix

```markdown
| Scenario Tag | Actions | Status |
|--------------|---------|--------|
| @us1-login-success | S010, S012-S015 | Pending |

**Coverage**: [X]/[Y] scenarios have linked actions ([Z]%)
```

### Coverage Validation

- Every @P1 scenario has at least one action
- Every @happy-path scenario has implementation actions
- Every @principles scenario has verification actions
- No orphan actions (actions without scenario links)

Write to `FEATURE_DIR/actions.md` using `.teammate/templates/actions-template.md`.

---

## Final Steps

### Update Agent Context

Run `.teammate/scripts/bash/update-agent-context.sh cursor-agent`.

### Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/active-context.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Commit (complete), Last Command: plan, Next Action: /teammate.execute
- **追加 `## Session Log`**：`| [timestamp] | plan | [N] scenarios, [N] tasks, [N] actions, [coverage]% | [key decisions] |`

### Report Completion

Output:
- Generated files list (`.feature`, `screenplay.md`, `tasks.md`, `actions.md`, contracts)
- Scenario summary: [N] scenarios across [N] stories
- Screenplay summary: [N] Actors, [N] Abilities, [N] Tasks
- Action summary: [N] total actions, [N] per story, [coverage]%
- Parallel opportunities identified
- Suggested next command: `/teammate.execute`

---

## Gherkin Writing Guidelines

### Tag Convention

```gherkin
@feature-name @P1           # Feature and priority
@happy-path                  # Primary success path
@alternative                 # Valid alternative flows
@negative                    # Error/failure scenarios
@boundary                    # Edge cases and limits
@principles                  # Principles boundary enforcement
@data-driven                 # Parameterized scenarios
```

### Step Writing Best Practices

**Given** — Context/State: "Given the user is logged in"
**When** — Action: "When the user submits the form"
**Then** — Outcome: "Then the user sees a confirmation message"

## Screenplay Pattern Reference

```
Actor (who?) → Task (what?) → Ability (how?) → System
```

## Action Principles

- **Atomic & Verifiable**: Small enough for one session, large enough to be meaningful
- **Traceable Chain**: `Scenario (@tag) → Action (S0XX) → Implementation → Verification`
- **Red-Green Loop Ready**: Step definitions before code, always RED first
- **Dependencies**: Models before services, services before endpoints, foundation before stories
