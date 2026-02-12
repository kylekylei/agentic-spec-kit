# Implementation Plan: [FEATURE]

**Branch**: `[###-feature-name]` | **Date**: [DATE] | **Spec**: `spec.md`

---

# Part 1: Tasks（技術規劃）

## Summary

[Extract from feature spec: primary requirement + technical approach]

## Technical Context

**Language/Version**: [e.g., TypeScript 5.0, Python 3.11]
**Framework**: [e.g., SvelteKit, FastAPI]
**Build Tool**: [e.g., Vite, Webpack]
**Styling**: [e.g., Tailwind CSS v4]
**Testing**: [e.g., Vitest, Playwright]
**Package Manager**: [e.g., pnpm, pip]
**Target Platform**: [e.g., Browser, Server]
**Performance Goals**: [domain-specific metrics]
**Constraints**: [domain-specific constraints]
**Scale/Scope**: [N User Stories, N FR, N Gherkin scenarios]

## Principles Check

*GATE: Must pass before proceeding*

| 原則 | 檢查項目 | 狀態 |
|------|----------|------|
| [Principle I] | [Check item] | ✅ PASS / ❌ FAIL |

## Actors & Abilities (optional)

> 大型 feature（≥5 stories）才產出此節。精簡版 Screenplay Pattern。

### Actors

| Actor | Abilities | Primary Goals |
|-------|-----------|---------------|
| [ACTOR] | [Ability1, Ability2] | [Goal] |

### Key Tasks

| Task | Actor | Scenarios Covered |
|------|-------|-------------------|
| [Task name] | [Actor] | [Scenario tags] |

## Project Structure

### Source Code

```text
[Concrete file/directory layout with markers]
```

File markers:
- `[NEW]` — New file to create
- `[ENHANCE]` — Existing file with functional changes
- `[INTEGRATE]` — Existing file that must import/mount a [NEW] component (pure wiring)

### Integration Impact Analysis

Every `[NEW]` UI component (not a child of another [NEW]) MUST have at least one `[INTEGRATE]` consumer:

```text
[NewComponent]          # [NEW]
[consumer-file]         # [INTEGRATE] 掛載 [NewComponent]
```

## Research & Decisions

> Fill if NEEDS CLARIFICATION items exist

| Decision | Rationale | Alternatives Rejected |
|----------|-----------|----------------------|

## Complexity Tracking

> Fill ONLY if Principles Check has violations that must be justified

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|

---

# Part 2: Actions（執行清單）

## Red-Green-Reflect Loop

每個 action 遵循以下流程：
1. **RED** — 寫 step definition / 測試 → 預期失敗
2. **GREEN** — 實作最少程式碼 → 測試通過
3. **REFACTOR** — 重構（如需要）
4. **REFLECT** — 快速自檢（≤30s），有新發現寫入 `insights.md`
5. **MARK** — 標記 action 完成 `[x]`

## Action Format

```
- [ ] [ActionID] [Type] [P?] [Story?] [Verifies: @scenario-tag(s)] Description with file path
```

- `[ActionID]`: Sequential (S001, S002, S003...)
- `[Type]`: **REQUIRED** — `[LOGIC]`, `[UI]`, or `[LOGIC+UI]`
- `[P]`: Parallel marker (optional — different files, no dependencies)
- `[Story]`: User story marker (US1, US2...)
- `[Verifies: @tag]`: Links to scenario tag(s) — **REQUIRED**

### RED/GREEN Forced Split

`[LOGIC]` 和 `[LOGIC+UI]` 涉及 util/store/service/model，MUST 拆為兩個連續 actions：

```markdown
- [ ] S010 [LOGIC] [US1] [Verifies: @tag] RED: 建立測試 in tests/...
- [ ] S011 [LOGIC] [US1] [Verifies: @tag] GREEN: 實作 in src/...
```

`[UI]` 類型不強制拆分。

---

## Phase 0: Setup

- [ ] S001 [LOGIC] [Verifies: @setup] ...

---

## Phase 1: Foundational

- [ ] S002 [LOGIC] [Verifies: @foundation] ...

**Checkpoint**: Foundation ready — user story implementation can begin

---

## Phase 2: [User Story 1 Title] (Priority: P1)

- [ ] S010 [LOGIC] [US1] [Verifies: @us1-happy-path] RED: ...
- [ ] S011 [LOGIC] [US1] [Verifies: @us1-happy-path] GREEN: ...
- [ ] S012 [UI] [US1] [Verifies: @us1-happy-path] ...

**Checkpoint**: User Story 1 independently testable

---

## Phase N: Polish & Cross-Cutting

- [ ] SXXX [Verifies: @cross-cutting @i18n] ...
- [ ] SXXX [Verifies: @cross-cutting @a11y] ...

---

## Traceability Matrix

| Scenario Tag | Actions | Status |
|--------------|---------|--------|
| @us1-happy-path | S010-S012 | Pending |

**Coverage**: [X]/[Y] scenarios have linked actions ([Z]%)

---

## Dependencies & Execution Order

- **Setup → Foundational**: BLOCKS all user stories
- **User Stories**: Can proceed in parallel after Foundational
- **Within each story**: RED before GREEN, models before services
- **Polish**: After all desired stories complete
