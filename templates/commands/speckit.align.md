---
description: Requirements alignment — run Impact Mapping + Example Mapping to produce spec.md + example-mapping.md.
handoffs:
  - label: Create work plan
    agent: speckit.plan
    prompt: Generate Gherkin scenarios, technical plan, and action checklist
    send: true
  - label: Continue editing spec
    agent: speckit.align
    prompt: Continue refining the current spec
  - label: Skip to execution
    agent: speckit.execute
    prompt: Start implementation — spec is sufficient, no further planning needed
    send: true
---

## User Input

```text
$ARGUMENTS
```

If user input is non-empty, **must** incorporate it before proceeding. Text after `/speckit.align` **is** the feature description — do not ask for it again.

## Overview

Single-pass **Impact Mapping + Example Mapping** workflow from the feature description.

### Mode Detection

- `$ARGUMENTS` contains `update` → **Update Mode** (re-read existing spec, preserve unchanged sections)
- `$ARGUMENTS` contains Pencil node IDs (`/`-separated paths), `.pen` file paths, or keywords like "design", "optimize", "UI adjustment" → **Design Mode** (see below)
- Otherwise → **Create Mode**

### Design Mode (Design Task Routing)

Triggered for design-oriented tasks: Pencil `.pen` modifications, Figma refinements, visual/UX adjustments.

**Execution flow**:
1. Phases 0–1 (foundation check + setup) — run as normal
2. Phase 2 (Impact Mapping) simplified to **Design Intent Mapping**:
   - WHO: Affected user roles
   - WHY: Design improvement goals (UX issues, visual consistency, usability)
   - WHAT: Specific design changes (observable, verifiable)
3. Phase 3 (spec writing) produces `contracts/ui/ui-spec.md` (replaces or supplements `spec.md`):
   - Design intent and problem description
   - Change item list (node/component mapping)
   - Visual verification criteria (screenshot-comparable)
4. Phases 4–5 (validation + Example Mapping) — optional for pure visual changes; required if interaction behavior changes
5. Design file edits may precede `spec.md` (`.pen` / Figma changes count as design document updates)
6. Phases 6–8 — run as normal

**Artifact mapping**:

| Standard Flow Artifact | Design Mode Artifact |
|------------------------|----------------------|
| `spec.md` | `contracts/ui/ui-spec.md` (required) + `spec.md` (only if behavior changes) |
| `example-mapping.md` | Optional (only if interaction behavior changes) |

**Revert to standard flow when**: design changes introduce new user behaviors, Principles boundary changes, or cross-module impact.

### Phase 0: Load Context

Load `context.md` (WHO/WHY/technical constraints + Principles behavioral boundaries).

**Conditional load**: Most recent completed task's `insights.md` (if exists) — UX/design lessons affect requirements quality.

**Figma URL Detection**: Scan `context.md` for Figma URLs (`figma.com/design/`, `/file/`, `/proto/`). If found → create `.specify/design/figma-index.md` (Project Figma table + empty Feature Pages table). If none → skip.

**experience-kit AC Seed Detection**:

> Cross-system integration: experience-kit → agentic-spec-kit
> Contract: see experience-kit `contracts/handoff-to-speckit.md`

Scan for experience-spec with §8 AC Seed:

| Artifact | Path Pattern | If Found |
| --- | --- | --- |
| experience-spec | `design/*-experience-spec-v*.md` | Read §4 + §8 |

**If experience-spec §8 AC Seed found:**
- §8 AC Seed → directly seed spec.md Acceptance Criteria (skip re-derivation from scratch)
- §8 `Addresses` field → map each AC to spec-contract SQ/DQ/LQ sub-characteristics
- §8 `Recipe` field → link AC to `composition-recipes.json` for implementation guidance
- §8 Data Contracts → seed spec.md Key Entities and validation rules
- §8 Form Validation → seed spec.md validation requirements
- §8 Error Recovery → seed spec.md error handling requirements
- §4 Design Expectations → cross-reference during Example Mapping (Phase 5)
- Record: `ac-seed-source: experience-spec v{X.Y} §8`

**Own / Enable AC 雙軌**（if spec-contract found with `responsibility` markings）:

Read spec-contract sub-characteristic responsibility markings. For each sub-characteristic addressed by AC Seed:

| Responsibility | AC Type | Naming | Verification |
| --- | --- | --- | --- |
| `own` | Direct AC | `AC-NNN` | 功能/E2E 測試 |
| `enable` | Contract AC | `AC-E-NNN` | 契約測試（Pact / JSON Schema / OpenAPI）。必填 `Supports: AC-NNN` |
| `ref` | No AC | — | 記錄至 context.md `## References` |

- Enable AC 語意模板：「提供 {結構} 以支援 {上層合規}」
- If AC Seed has `composition_recipe_ref` → AC-E references recipe as implementation guidance
- 缺口檢查：spec-contract Required sub-char 無對應 AC → WARN

**AC Seed 修改注記**：

When spec-kit modifies AC Seed content during alignment (e.g., splitting, merging, rewording):
- Record diff in spec.md header: `ac-seed-delta: [modified scenario IDs]`
- If AC Seed conflicts with spec-contract Required sub-char → **暫停執行，請人類做決策**，記錄至 `principles.md`

**If §8 is missing but §4 exists:**
- Derive AC from §4 Design Expectations (standard path, slower)
- WARN: "AC Seed not available — deriving from §4 Design Expectations. Consider re-running /x.scenario to generate §8."

**If no experience-spec found:** proceed with standard flow (no cross-system input).

### Phase 1: Setup

1. **Generate branch name** (2–4 words, verb-noun format, e.g. `add-user-auth`)

2. **Check existing branch numbers**:
   - Scan remote, local branches, and `specs/` — use N+1
   - Run `skills/speckit/scripts/bash/create-new-spec.sh --json "$ARGUMENTS"`
   - Escape single quotes: `'I'\''m Groot'`

### Phase 2: Impact Mapping

Derive valuable behaviors:

1. **WHO (Actors)**: Identify all roles (primary users, secondary users, system roles, admin roles) — define name, goal, pain point
2. **WHY (Business Goals)**: Define business impact, measurement, cost of not building; link actors to goals
3. **HOW (Capabilities)**: Identify capabilities needed to achieve goals
4. **WHAT (Features/Behaviors)**: Derive concrete behaviors from capabilities — each must be observable, testable, independently deliverable

### Phase 3: Spec Writing

1. Load `templates/spec-template.md`
2. Fill in the spec:
   - Map Impact Mapping results to User Stories
   - Infer ambiguities from context; only mark `[NEEDS CLARIFICATION]` when scope impact is significant (**max 3**)
   - Generate Functional Requirements (testable), Success Criteria (measurable, technology-agnostic), Key Entities
3. Write to `SPEC_DIR/spec.md`

   > **Conciseness constraint**: Follow the template; max 5 bullet points per section; max 10 User Stories; success criteria as single measurable sentences — no paragraph-style expansion.

### Phase 4: Spec Validation

1. Generate `SPEC_DIR/checklists/requirements.md`
2. Validation criteria: no implementation details, user-value focused, targets non-technical stakeholders, requirements are testable and unambiguous, success criteria are measurable
3. Failure → update spec (max 3 iterations); remaining `[NEEDS CLARIFICATION]` → present options to user

### Phase 5: Example Mapping

Convert User Stories into concrete, testable examples as a foundation for Gherkin scenarios. Ask up to 3 supplementary questions if needed — do not interrupt the flow.

For each User Story (in P1 → P2 → P3 priority order):

> **Conciseness constraint (P2/P3)**: P2 and P3 rules need **only a one-line summary** each (format: `- [rule name]: [boundary condition in one sentence]`). Only P1 rules get fully expanded examples and boundaries.

1. **Story Card**: As a / I want / So that format — confirm business value
2. **Rules Discovery**: Identify business rules (conditions, constraints, allowed variants, principles boundaries) — each must be clearly testable
3. **Examples Generation**:
   - **P1 rules**: At least happy path + alternative (if applicable) + negative example + boundary conditions per rule, using Given/When/Then
   - **P2/P3 rules**: One-line summary only, format: `- [rule name]: [boundary condition in one sentence]`
4. **Questions Collection**: Record ambiguities (impact: High/Medium/Low); raise High-impact questions directly (max 3) with suggested options

On completion:
- **Principles Boundary Check**: Validate against principles; add boundary examples
- Write to `SPEC_DIR/example-mapping.md` using the template
- **Readiness assessment**: Rules >= 3/story, Examples >= 2/rule, Open questions 0 high-impact, Principles boundaries >= 1/story

### Phase 6: Downstream Impact Check (Update Mode only)

If `SPEC_DIR/plan.md` exists:
- Compare spec.md changes vs plan.md (added/removed Stories → scenarios need update, FR changes → architecture may need adjustment, new rules → may need new scenarios)
- Structural changes → mark `OUTDATED`, recommend `/speckit.plan update`
- Wording-only fixes → mark `UP-TO-DATE`

### Phase 7–8: Finalize

Per `speckit/references/command-shared` — Update Active Context + Completion Report.

- **Phase**: align
- **Last**: align — [task name], spec.md + example-mapping.md created
- **Next**: /speckit.plan
- Include: branch name, file paths, Impact Mapping summary, Example Mapping summary, readiness status


## Behavioral Rules

> Common rules: see `speckit/references/command-shared`.

- Focus on **WHO/WHAT/WHY** — no HOW implementation details
- Every behavior: observable, testable, linked to business goal
- Success criteria: measurable, technology-agnostic, user-oriented
- Update Mode preserves unchanged sections
- Max 3 inline questions per session
- Always produce spec.md + example-mapping.md (mark as draft if questions remain)
- P1 stories get priority for principles boundary examples
