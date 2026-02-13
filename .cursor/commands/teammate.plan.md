---
description: Generate Gherkin scenarios and a unified implementation plan (tasks + actions) in one pass. Produces .feature files + plan.md + contracts/ui/ui-spec.md (if UI).
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

Goal: Transform the aligned spec and examples into a complete execution plan — **Gherkin scenarios** (WHAT to verify) and a unified **plan.md** containing both technical tasks (HOW to build) and atomic actions (STEPS to execute).

### Mode Detection

Parse `$ARGUMENTS` for keywords:

- `update` → **Update Mode** (preserve existing work, snapshot before changes, mark with `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`)
- `--ui` → **Force UI Deep Analysis** (even if < 3 UI components)
- Otherwise → **Create Mode** (default; UI Deep Analysis auto-triggered if ≥ 3 UI components)

### Phase 0: Foundation Check

1. **Read `.teammate/memory/context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.init` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.init` first."

### Update Mode

When running with `update`, the command preserves existing work:

1. **Pre-Update Snapshot**: Copy existing `plan.md`, `scenarios/*.feature` to `.teammate/snapshots/`
2. **Ask user**: "What changed and why?" (one line)
3. **Diff-Aware Processing**: Compare baseline against current spec/examples
4. **Mark changes**: `[UNCHANGED]`, `[NEW]`, `[REVISED]`, `[REMOVED]`
5. **Sync Contracts** (if `contracts/ui/` exists): Update stale entries in `ui-spec.md`
6. **Impact Report**: Count unchanged/new/revised/removed items
7. **Never discard completed work** — removed items are commented out, not deleted

---

## Stage 1: Scenario Generation

> 產出：`TASK_DIR/scenarios/*.feature` + `teammate.refs.yaml`

### Setup

1. Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root. Parse JSON for `TASK_DIR`, `TASK_SPEC`.

2. **Load Context**:

   Required:
   - `TASK_DIR/spec.md` - User stories and requirements
   - `TASK_DIR/example-mapping.md` - Rules and examples
   - `.teammate/memory/principles.md` - Non-negotiable boundaries

   Optional:
   - `.teammate/templates/feature-template.feature` - Gherkin template
   - `TASK_DIR/contracts/ui/design-principles.md` - UX 設計原則

3. **Create Features Directory**: `mkdir -p TASK_DIR/scenarios`

### UX Conflict Scan (if `design-principles.md` exists)

在產生 scenarios 之前，強制執行設計原則衝突分析：

1. **設計原則 vs 核心原則交叉比對**: API 可行性、是否需新增後端 endpoint
2. **互動元素可行性檢查**: 每個 UI action 需要的後端能力是否存在
3. **參考設計語意差異**: 外部參考產品的操作語意 vs 本專案操作語意
4. **Conflict Report**: 有 CONFLICT 或 SEMANTIC_GAP 時暫停讓使用者決策

### Scenario Generation

For each User Story (in priority order):

1. **Generate `.feature` file** with proper header, Background, and tagged Scenarios
2. **Map Example Mapping** rules → scenarios, examples → Given/When/Then
3. **Add Principles Boundary Scenarios** (`@principles @boundary`)
4. **Consolidate data-driven scenarios** using Scenario Outline where applicable
5. **Write** to `TASK_DIR/scenarios/[story-slug].feature`

### Context Anchors

Create/update `TASK_DIR/teammate.refs.yaml` with feature metadata, behavior references, and dependencies.

### Coverage Validation

Requirements: Every rule → at least one scenario. Every P1 story → happy path + negative. Every principles boundary → a scenario.

### Gherkin Quality Check

- Each scenario is independent (can run in isolation)
- Steps are declarative (WHAT, not HOW)
- No implementation details in steps
- Tags follow convention (@P1/@P2/@P3, @happy-path, etc.)

---

## Stage 2: Implementation Plan — Part 1: Architecture

> 產出：`TASK_DIR/plan.md` 的 Part 1（技術架構）

### Load Additional Context

Optional（如存在則載入）:
- `.teammate/memory/agent-spec.md` → AI Agent 行為規範（如專案有 AI Agent 角色）
- `docs/llms.txt` → 外部 API/SDK 參考索引（遵循 llms.txt 標準）
- `TASK_DIR/example-mapping.md`

### Design Asset Detection（動態）

檢查 `.teammate/design/figma-index.md` 是否存在：

- **If exists** → UI Deep Analysis **必定觸發**（無需滿足 ≥3 組件條件）
  1. Load as design context
  2. Append current feature page link to `figma-index.md` Feature Pages table (if user provides)
  3. **Enable `contracts/ui/ui-spec.md` generation** in Stage 2.5
- **If not exists** → 僅在 `--ui` flag 或 ≥3 UI 組件時觸發 UI Deep Analysis

### Compliance Detection（動態）

掃描 `context.md` tech stack + codebase 自動偵測：

1. **前端偵測**（*.tsx/*.vue/*.svelte/*.html 或 react/vue/svelte 依賴）→ 在 Architecture 區段標記：
   > ⚠️ **A11y Compliance 已啟用**：所有 UI 組件需符合 WCAG 2.2 AA。建議為每個互動元素規劃 aria 屬性、鍵盤導航與色彩對比。參考 `.cursor/skills/a11y-compliance/SKILL.md`。

2. **AI/LLM 偵測**（openai/anthropic/langchain import 或 chat/completion API）→ 在 Architecture 區段標記：
   > ⚠️ **AI Risk Compliance 已啟用**：AI 互動介面需符合 EU AI Act Art. 50 透明度義務。建議規劃 AI 揭露標籤、同意機制、內容標示、人類覆寫控制。參考 `.cursor/skills/ai-compliance/SKILL.md`。

若 context.md 無標記但 codebase 偵測到 → 額外提示更新 context.md。

### Test Infrastructure Check

1. **檢查既有測試框架**: 掃描 `package.json` (vitest/jest/playwright), `pytest.ini`, `go.mod` 等
2. **若不存在**: 在 plan.md 新增 Phase 0 必要 setup（測試框架設定、測試目錄、mock setup）
3. **若已存在**: 記錄在 Technical Context 中

### Technical Planning

1. **Technical Context**: Language/Version, Dependencies, Storage, Testing framework, Constraints
2. **Principles Check**: Map each principle to technical decisions. *GATE: Must pass*
3. **Actors & Abilities** (optional, ≥5 stories): Identify actors from scenarios, define roles, abilities, key tasks
4. **Project Structure**: Source structure with file markers:
   - `[NEW]` — New file to create
   - `[ENHANCE]` — Existing file with functional changes
   - `[INTEGRATE]` — Existing file that must import/mount a [NEW] component (pure wiring)

### Integration Impact Analysis

For every `[NEW]` component, identify its **consumer** (existing file that must import/mount it):
- Every `[NEW]` UI component (not a child of another [NEW]) MUST have at least one `[INTEGRATE]` consumer
- Common integration points: layout files (global), page files (route-specific), parent components

### Research & Decisions

If NEEDS CLARIFICATION items exist: Generate research tasks, consolidate in plan.md Research section.

---

## Stage 2.5: UI Deep Analysis (auto-triggered or --ui)

> 產出：`TASK_DIR/contracts/ui/ui-spec.md`（統一 UI 規格）

**觸發條件**（滿足任一）:
1. `.teammate/design/figma-index.md` 存在（表示專案有設計資產）
2. spec.md + Project Structure 中 `[NEW]`/`[ENHANCE]` UI 組件數量 ≥ 3
3. 使用者指定 `--ui` flag

> 若無 `figma-index.md` 且未達觸發條件，此階段跳過，不產生 `contracts/ui/ui-spec.md`。

### Component Inventory

掃描 spec.md 和 plan.md Project Structure，列出所有 UI 組件：

| 組件 | 類型 | 狀態數 | 父組件 | 備註 |
|------|------|--------|--------|------|
| [ComponentA] | [Panel/Card/...] | [N] | [parent] | [notes] |

### Props & Interface

For each component: Props, exported interface, key events, slot structure.

### State Matrix

For each component, define complete visual states:

| 狀態 | 觸發條件 | 外觀描述 | 互動行為 |
|------|----------|----------|----------|

Rules:
- 每個組件 MUST 至少 3 種狀態（預設 + 主要 + 邊界）
- Loading/Error/Empty 狀態 MUST 說明內容和使用者動作

### Interaction Flows

Define core interaction paths (happy path + error path) as step sequences.

### Interactive State Machine

For each interactive element:

| 元素 | 觸發條件 | 狀態 | 行為 |
|------|----------|------|------|

Rules: 每個互動元素 MUST 有 enabled + disabled；若引用外部設計 MUST 標註語意差異。

### Design System Compliance

- UI: color tokens, spacing scale, typography
- i18n: all visible text uses i18n keys, synced to all locales
- a11y: aria-label, keyboard nav, focus management, contrast ≥ 4.5:1

Write all to `TASK_DIR/contracts/ui/ui-spec.md`.

---

## Stage 3: Implementation Plan — Part 2: Actions

> 產出：`TASK_DIR/plan.md` 的 Part 2（執行清單）

### Extract Scenario Tags

Parse all `.feature` files to build tag inventory.

### Generate Actions by User Story

#### Action Format

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

- `[Type]`: **REQUIRED** — `[LOGIC]`, `[UI]`, or `[LOGIC+UI]`
- RED/GREEN Forced Split: `[LOGIC]` 涉及 util/store/service/model MUST 拆為 RED + GREEN 兩個 actions
- `[UI]` 不強制拆分

#### Integration Actions

For every `[INTEGRATE]` file in Part 1 Project Structure, generate a mount/import action immediately after the component creation action.

### Phase Structure

- **Phase 0: Setup** — Project initialization, test infrastructure
- **Phase 1: Foundational** — Core infrastructure
- **Phase 2+: User Stories** — Story-specific actions (step definitions first, then implementation)
- **Phase N: Polish** — Cross-cutting concerns

### Traceability Matrix

| Scenario Tag | Actions | Status |
|--------------|---------|--------|

Coverage: [X]/[Y] scenarios ([Z]%)

### Write plan.md

Write the complete plan (Part 1 + Part 2) to `TASK_DIR/plan.md` using `.teammate/templates/plan-template.md`.

---

## Final Steps

### Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/progress.md` using delta mode:
- **覆寫 `## Current State`**：Phase: Commit (complete), Last Command: plan, Next Action: /teammate.execute
- **追加 `## Session Log`**：`| [timestamp] | plan | [N] scenarios, plan.md ([N] tasks, [N] actions), [coverage]% | [key decisions] |`

### Report Completion

Output:
- Generated files list (`.feature`, `plan.md`, `contracts/ui/ui-spec.md` if triggered)
- Scenario summary: [N] scenarios across [N] stories
- Plan summary: Part 1 Architecture ([N] technical decisions), Part 2 Actions ([N] actions, [coverage]%)
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

## Action Principles

- **Atomic & Verifiable**: Small enough for one session, large enough to be meaningful
- **Traceable Chain**: `Scenario (@tag) → Action (S0XX) → Implementation → Verification`
- **Red-Green-Reflect Loop Ready**: Step definitions before code, always RED first, REFLECT after GREEN
- **Dependencies**: Models before services, services before endpoints, foundation before stories
