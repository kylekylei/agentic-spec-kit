---
description: Implementation execution — iterate through Actions in Red-Green-Verify-Refactor-Reflect-Dialogue loop order.
handoffs:
  - label: Behavior coverage review
    agent: speckit.review
    prompt: Run behavior coverage analysis
    send: true
---

## User Input

```text
$ARGUMENTS
```

## Overview

- Execute via **Test-First loop** — every line of code driven by a failing test
- Write tests directly (jest/vitest/pytest/playwright), no Gherkin translation

### Argument Parsing

Parse `$ARGUMENTS` for special keywords:

| Keyword | Behavior |
|---------|----------|
| `next` | Find the next incomplete action (`- [ ]`) in `plan.md` Part 2 and execute it |
| `S0XX` | Execute a specific Action ID (e.g., `S006`) |
| `S0XX-S0YY` | Execute a range of actions (e.g., `S006-S010`) |
| _(empty)_ | Start from the beginning or resume from last interruption |
| _(other text)_ | Treat as task description; find the best-matching action |

#### `next` Mode Flow

1. Read `SPEC_DIR/plan.md` Part 2, find the first `- [ ]` action
2. Skip all `- [x]`
3. Display: "**Executing S0XX**: [action description]" then enter Red-Green Loop
4. On completion, mark `- [x]` and report the next pending action

### Loop Overview

```
RED → GREEN → VERIFY → REFACTOR → REFLECT → DIALOGUE → REPEAT
```

### Execution Steps

1. **Setup**: Run prerequisites check (see `speckit/references/command-shared`) with `--json --require-plan --include-plan`. Parse `SPEC_DIR`, `AVAILABLE_DOCS`.

2. **Check Checklist Status** (if `SPEC_DIR/checklists/` exists): Scan all checklist files, count complete/incomplete. If incomplete items exist, pause and ask. If all complete, continue automatically.

3. **Load Execution Context**:

   Run `skills/speckit/scripts/bash/load-execution-context.sh --json` and load files per output:
   - `required`: Always load (plan.md, spec.md Acceptance Criteria)
   - `loaded`: Load if present (insights, contracts, llms.txt, etc.)
   - `compliance`: Auto-detected compliance Skills (a11y / AI Risk)

   **Staleness Check**: If `spec.md` modified more recently than `plan.md`, warn "plan may be stale" and suggest `/speckit.plan update`.

   - Never skip `loaded` resources to save context

4. **Project Config Validation**: Detect tech stack and create/verify ignore files (`.gitignore`, `.dockerignore`, etc.).

5. **Parse Plan Structure**: Extract from `plan.md` Part 2: Phases, Actions, `[Verifies: AC-001]`, `[P]` parallel markers, Action types.

6. **Risk-Based HITL Gates**:

   Before executing each action, check these risk conditions. Pause and ask user when triggered:

   | Risk Trigger | Pause Behavior |
   |-------------|---------|
   | AC touches Principles boundary or modifies Principles boundary code | Confirm to continue? |
   | Requires file deletion or rename | Confirm delete/rename? |
   | Modifies shared infrastructure (config, shared utils, store, layout) | Confirm impact scope? |
   | Introduces a pattern not present in codebase | Confirm new pattern? |

   User may reply "continue" or "adjust." Log pause events to `context.md` Current section.

7. **Execute Red-Green Loop**:

   #### Action Type Detection

   | Type | RED Phase | GREEN Phase |
   |------|---------|-----------|
   | `[DESIGN]` | spec.md Acceptance Scenarios (visual verification checklist) | Design artifact changes (Pencil / Figma) + screenshot verification |
   | `[LOGIC]` | Write unit test (expect RED) | Write minimal implementation to make test GREEN |
   | `[UI]` | **Smart triage** (see below) | Implement UI component |
   | `[LOGIC+UI]` | Write unit test + smart triage | Implement logic + UI |

   > If action has no type tag, infer from description: .pen/.figma/design keywords -> `[DESIGN]`; model/store/service/util -> `[LOGIC]`; .svelte/.tsx/.vue -> `[UI]`; both -> `[LOGIC+UI]`.

   #### UI Smart Triage

   | Scenario | Behavior |
   |----------|---------|
   | Figma link or sibling component available for reference | Implement directly |
   | Uncertain details (props/state/interaction) | Use `AskQuestion` with structured options; implement after confirmation |
   | No reference at all | Pause, present visual spec for confirmation, then implement |

   Inference sources: `contracts/ui/`, `context.md` Principles section, sibling component conventions from `insights.md`.

   #### Test-First Flow (All Action Types)

   > **Output Constraints (Hard Rule)**:
   > - **Never** output entire files, repeat existing code, or emit unrelated boilerplate.
   > - Output **only the function body** or specific code fragment, with insertion location (line number or anchor).
   > - For new files, output only the minimal code directly relevant to this Action.

   1. **RED** (`[LOGIC]`/`[LOGIC+UI]`): Write test code (jest/vitest/pytest/playwright) based on the `[Verifies: AC-001]` Acceptance Criteria — no Gherkin translation
   2. Run test — expect **RED** (failure)
   3. **GREEN**: Write minimal implementation to make the test pass

   4. **VERIFY Phase**:

      a. Read `speckit.yml` `verification.test_command` (auto-detect framework if null)

      b. **First-run confirmation** (only once per task): Check if `speckit.yml` has `test_command_confirmed`. If not: `[A]` Confirm / `[B]` Modify / `[C]` Skip

      c. Run the relevant test (find test file via `[Verifies: AC-001]`)

      d. **Result handling**:
         - **GREEN (exit 0)**: Mark passed, proceed to REFACTOR
         - **RED (exit 1)**: Parse failing tests -> `[A]` Debug implementation / `[B]` Fix test / `[C]` View logs -> enter debug loop
         - **Environment error (exit != 0/1)**: Prompt environment issue -> `[A]` Fix environment / `[B]` Manually specify command / `[C]` Skip verification

      **Skip verification rules**: Choosing `[C] Skip` requires user to type `SKIP` to confirm. After skipping:
      - Record `WARNING SKIPPED VERIFY: [ActionID]` in `context.md` Current section
      - Mark action as `unverified` (not `pass`); use `- [~]` in plan.md
      - Review phase will flag unverified actions as MEDIUM risk

      e. Record in `git commit` message: `execute [ActionID] [GREEN/RED] AC-001`

   #### REFACTOR Phase

   After all actions in a story are GREEN: review duplication, apply patterns, confirm tests still GREEN, commit with story reference.

   #### REFLECT Phase (Hard Gate — cannot be skipped)

   After each action goes GREEN, **must** perform a <=30-second self-check:

   1. Codebase conventions/patterns?
   2. Pitfalls or caveats?
   3. Technical decisions or trade-offs worth recording? (trade-offs → Decision Log)
   4. Prior insights needing correction?
   5. Insight recurring 3+ tasks? → suggest graduating to `context.md` Principles

   **Rules**:
   - Every action **must** write to `SPEC_DIR/insights.md` (write findings if any; write `No new insights` if none)
   - Format: `- [S0XX] Finding content`; copy from template on first write
   - Completion evidence: report must include `REFLECT: done`
   - **No batch backfilling**
   - **Iteration tracking**: If a completed action is revisited due to user feedback or bug fix, append an iteration record to the corresponding `insights.md` section (fix reason, root cause, lesson learned); if new design decisions or issues arise, add a new D-0XX section

   #### DIALOGUE Phase (Conversational Sync)

   After REFLECT, apply **minimal intervention principle** — only trigger dialogue for these two cases:

   | Trigger | Behavior |
   |---------|---------|
   | Implemented public interface (endpoint / prop / function) **exceeds** the behavior scope of `[Verifies: AC-001]` | Offer: `[A]` Intentional expansion (update spec + plan) / `[B]` Scope creep (remove) / `[C]` Defer (log as Technical Debt) / `[D]` Ignore |
   | Introduces a new system layer not marked in `plan.md` System Scope (e.g., new `openai` import when LLM is marked as excluded) | Confirm then update System Scope + Compliance Requirements; if cancelled, log as Technical Debt |

   All other cases (refactoring, bug fixes, implementation details) — **skip DIALOGUE** and proceed to the next action.

8. **Parallel Execution Rules**: Actions marked `[P]` may run in parallel if they modify different files, have no dependencies, and verify independent scenarios.

9. **Progress Tracking**: After each action completes, mark `[x]` in `plan.md` and report progress. On failure, report error and do not continue with dependent actions.

10. **Phase Completion Sync**: When all Phase actions complete, update `context.md` § Current.

11. **Finalize**: Per `speckit/references/command-shared` — Update Active Context + Completion Report.
    - **Phase**: execute
    - **Last**: execute [ActionID] — [GREEN/RED]
    - **Next**: [next action or /speckit.review]
    - All scenarios GREEN + all actions done → suggest `/speckit.review`


## Execution Order

Setup → Design → Foundation → Stories (P1→P2→P3) → Polish. Tests before code. Commit after each GREEN.

## Error Handling

On action failure:
- Report error with full context
- Show failing scenario and steps
- Suggest fix
- Wait for user instruction
- Do not continue dependent actions

For parallel actions:
- Continue successful ones
- Report failed ones
- User may choose to fix or skip
