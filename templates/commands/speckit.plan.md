---
description: Implementation view — produce plan.md (Architecture + Actions) driven by Acceptance Criteria.
handoffs:
  - label: Execute actions
    agent: speckit.execute
    prompt: Start Red-Green Loop implementation
    send: true
  - label: Review coverage
    agent: speckit.review
    prompt: Run behavior coverage analysis before execution
    send: true
---

## User Input

```text
$ARGUMENTS
```

If user input is non-empty, **must** consider its content before proceeding.

## Overview

- Transform aligned spec + examples into **plan.md** (Architecture + Actions)
- Driven by **Acceptance Criteria** (technical HOW + atomic STEPS)
- BDD Feature Files deferred to `/speckit.review`

### Mode Detection

- `update` → **Update Mode** (preserve existing artifacts, snapshot before changes, mark `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`)
- `--ui` → **Force UI Deep Analysis** (even if < 3 UI components)
- Otherwise → **Create Mode** (default; auto-triggers UI Deep Analysis if >= 3 UI components)

### Phase 0: Load Context

Per `speckit/references/command-shared`. Load `context.md`.

### Update Mode

When invoked with `update`:
1. Copy existing `plan.md` to `.specify/snapshots/`
2. Ask user: "What changed and why?"
3. Diff-aware processing: compare baseline vs current spec/examples
4. Mark changes: `[UNCHANGED]`/`[NEW]`/`[REVISED]`/`[REMOVED]`
5. Sync contracts (if `contracts/ui/` exists)
6. Impact report + preserve completed work (removed items become comments)

---

## Phase 1: Acceptance Criteria Validation

> Source: `spec.md` Acceptance Criteria

### Setup

1. Run prerequisites check (see `speckit/references/command-shared`) with `--json --paths-only`. Get `SPEC_DIR`, `SPEC_PATH`.
2. **Load context**:
   - Required: `spec.md`, `example-mapping.md`
   - Optional: `contracts/ui/design-principles.md`

### UX Conflict Scan (if `design-principles.md` exists)

Cross-check `contracts/ui/design-principles.md`:

| Finding | Action |
|---------|--------|
| No conflict between design principles and core principles | Proceed |
| `CONFLICT` (API feasibility, backend endpoints, interactive elements) | Pause with `AskQuestion`. Options: fix design principles / add backend capability / adjust semantic alignment / flag as tech debt |
| `SEMANTIC_GAP` (reference design semantic divergence) | Same as above |

### AC Coverage Validation

Verify `spec.md` Acceptance Criteria cover:
- Every P1 story → happy path + negative AC
- Every Example Mapping rule → >= 1 AC
- Principles boundaries → >= 1 AC

Coverage gaps → suggest additional ACs for `spec.md`.

---

## Phase 2: Implementation Plan — Part 1: Architecture

> Output: `SPEC_DIR/plan.md` Part 1 (technical architecture)

### Load Additional Context

Conditional (load if exists): last 2 completed tasks' `insights.md`

Optional: `agent-spec.md`, `docs/llms.txt`, `example-mapping.md`

### Design Asset Detection

- `.specify/design/figma-index.md` **exists** → always trigger UI Deep Analysis + enable `contracts/ui/ui-spec.md`
- **Does not exist** → trigger only with `--ui` flag or >= 3 UI components

### Compliance Detection & System Scope Detection

Run `skills/speckit/scripts/bash/detect-system-scope.sh --json` and parse output:
- `layers`: enabled system layers (frontend / backend / llm / database / mobile)
- `compliance`: corresponding requirements (a11y / security-owasp / ai-risk / mobile-a11y)
- `missing_context`: if flagged → prompt user to update `context.md`

Build **System Scope table** (Layer/Status/Evidence/Added) from `layers` result and insert at the top of `plan.md`.

### Technical Planning

1. **Technical Context**: language/version, dependencies, storage, test framework, constraints
2. **Principles Check**: map each principle to a technical decision. *GATE: must pass*
3. **Actors & Abilities** (optional, >= 5 stories)
4. **Project Structure**: mark files `[NEW]`/`[ENHANCE]`/`[INTEGRATE]`
5. **Type Definition Artifacts** (choose as needed): `types.d.ts` (frontend / Node), `schema.sql` (DB), Interface / Protobuf definitions. Generate boundary-clear types from `spec.md` Key Entities and Success Criteria.

### Integration Impact Analysis

Every `[NEW]` UI component (non-child) MUST have at least one `[INTEGRATE]` consumer. Common integration points: layout, page, parent component.

### Research & Decisions

If NEEDS CLARIFICATION exists → generate research tasks, consolidate in plan.md Research section.

---

## Phase 2.5: UI Deep Analysis (auto-triggered or --ui)

> Output: `SPEC_DIR/contracts/ui/ui-spec.md`

**Trigger conditions** (any): `figma-index.md` exists / UI components >= 3 / `--ui` flag. Skip if none met.

Write per `skills/speckit/references/ui-spec-format.md` format, covering: component inventory, property interfaces, state matrix (>= 3 states), interaction flows, interaction state machines, design system compliance (tokens / i18n / a11y).

Write all to `SPEC_DIR/contracts/ui/ui-spec.md`.

---

## Phase 3: Implementation Plan — Part 2: Actions

> Output: `SPEC_DIR/plan.md` Part 2 (execution checklist)

### Action Format

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: AC-001] Description with file path
```

- `[Type]` **REQUIRED**: `[DESIGN]`/`[LOGIC]`/`[UI]`/`[LOGIC+UI]`
- `[DESIGN]` — design artifact changes (Pencil / Figma), no code. MUST precede same-story `[UI]`/`[LOGIC]` actions
- `[LOGIC]` involving util/store/service/model MUST split into RED + GREEN actions
- `[UI]` does not require splitting
- Each `[INTEGRATE]` file generates a mount/import action immediately after its component creation action
- **Keep each Action Description to a single line**: focus on "what to do", exclude implementation details.

### Phase Structure

- **Phase: Setup** — project initialization, test infrastructure
- **Phase: Design** — design artifact changes (Pencil / Figma), must precede code implementation (skip if no design tasks)
- **Phase: Foundational** — core infrastructure
- **Phase: User Stories** — step definitions first, then implementation
- **Phase: Polish** — cross-cutting concerns

> Phases follow the order above. Skip Design Phase if no design tasks. AI assigns phase numbers based on actual phases present.

### Traceability Matrix

AC ID → Actions → Status. Coverage: [X]/[Y] Acceptance Criteria ([Z]%)

Write to `SPEC_DIR/plan.md` using `templates/plan-template.md`.

---

## Final Steps

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: plan
- **Last**: plan — [N] actions, [N] scenarios
- **Next**: /speckit.execute
- Include: artifact list, scenario summary, plan summary, parallelism opportunities

## Action Principles

> Atomic, traceable, test-first, design-before-code, dependency-ordered. See Phase 3 for details.
