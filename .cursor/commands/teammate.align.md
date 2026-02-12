---
description: Define what to build via Impact Mapping and clarify requirements via Example Mapping. Produces spec.md + example-mapping.md in one pass.
handoffs: 
  - label: Create Work Plan
    agent: teammate.plan
    prompt: Generate Gherkin scenarios, technical plan, and actions
    send: true
  - label: Continue Editing Spec
    agent: teammate.align
    prompt: Continue refining the current spec
  - label: Skip to Execute
    agent: teammate.execute
    prompt: Start implementing — spec is sufficient, no further planning needed
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

The text the user typed after `/teammate.align` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description, execute the **Impact Mapping + Example Mapping** workflow in one pass.

### Mode Detection

Parse `$ARGUMENTS` for the keyword **`update`**:

- If `$ARGUMENTS` contains "update" → **Update Mode** (re-read existing spec, apply changes, preserve unchanged sections)
- Otherwise → **Create Mode** (default)

### Phase 0: Foundation Check

1. **Read `.teammate/memory/context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.init` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found → **ERROR**: "Principles not defined. Run `/teammate.init` first."

3. **If both pass** → Load both files as working context:
   - context.md provides WHO (actors), WHY (business goals), and technical constraints
   - principles.md provides behavioral boundaries and invariants

4. **Figma URL Detection（動態設計資產建立）**
   - Scan `context.md` for Figma URL patterns: `figma.com/design/`, `figma.com/file/`, `figma.com/proto/`
   - **If Figma URL found**:
     1. Create `.teammate/design/` directory if not exists
     2. Create/update `.teammate/design/figma-index.md` using template:
        ```markdown
        # Figma Design Index
        
        > 此檔案由 `/teammate.align` 自動建立，當 `context.md` 包含 Figma URL 時觸發。
        
        ## Project Figma
        
        | 名稱 | URL | 說明 |
        |------|-----|------|
        | [從 context.md 提取的名稱或 "Main Design"] | [URL] | 專案主設計檔 |
        
        ## Feature Pages
        
        <!-- /teammate.plan 執行時會在此追加 feature-specific 頁面連結 -->
        
        | Feature | Page URL | 狀態 |
        |---------|----------|------|
        ```
     3. Log: "Figma URL detected → `.teammate/design/figma-index.md` created"
   - **If no Figma URL** → Skip (no design artifact created)

### Phase 1: Setup

1. **Generate a concise short name** (2-4 words) for the branch:
   - Analyze the feature description and extract the most meaningful keywords
   - Use action-noun format when possible (e.g., "add-user-auth", "fix-payment-bug")
   - Preserve technical terms and acronyms

2. **Check for existing branches before creating new one**:

   a. Fetch all remote branches:
      ```bash
      git fetch --all --prune
      ```

   b. Find the highest feature number across all sources for the short-name:
      - Remote branches: `git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - Local branches: `git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - Task directories: Check for directories matching `tasks/[0-9]+-<short-name>`

   c. Use N+1 for the new branch number.

   d. Run `.teammate/scripts/bash/create-new-task.sh --json "$ARGUMENTS"` with the calculated number and short-name.
      - For single quotes in args, use escape syntax: e.g 'I'\''m Groot'

### Phase 2: Impact Mapping

Execute the Impact Mapping framework to derive valuable behaviors:

#### WHO (Actors)

1. **Identify all actors** who will interact with this feature:
   - Primary users (who directly benefits)
   - Secondary users (who uses the output)
   - System actors (external systems, AI agents)
   - Administrative actors (who manages/configures)

2. For each actor, define: Role name, Primary goals, Current pain points

#### WHY (Business Goals)

3. **Define the business impact** this feature should create:
   - What business outcome does this enable?
   - How will we measure success?
   - What happens if we don't build this?

4. Connect each actor to business goals.

#### HOW (Capabilities)

5. **Identify capabilities** needed to achieve the goals.

#### WHAT (Features/Behaviors)

6. **Derive concrete behaviors** from capabilities:
   - Each behavior must be observable, testable, and deliver value independently

### Phase 3: Specification

1. Load `.teammate/templates/spec-template.md` to understand required sections.

2. **Fill the specification**:
   - Parse user description from Input (if empty: ERROR)
   - Map Impact Mapping results to User Stories
   - For unclear aspects: make informed guesses based on context
     - Only mark with [NEEDS CLARIFICATION: specific question] if the choice significantly impacts scope
     - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
   - Fill User Scenarios & Testing section (prioritize by business value)
   - Generate Functional Requirements (each must be testable)
   - Define Success Criteria (measurable, technology-agnostic)
   - Identify Key Entities (if data involved)

3. Write the specification to `FEATURE_DIR/spec.md`.

### Phase 4: Specification Validation

1. **Create Spec Quality Checklist**: Generate `FEATURE_DIR/checklists/requirements.md`

2. **Validate** against criteria:
   - No implementation details (languages, frameworks, APIs)
   - Focused on user value and business needs
   - Written for non-technical stakeholders
   - Requirements are testable and unambiguous
   - Success criteria are measurable and technology-agnostic

3. **Handle Validation Results**:
   - If all items pass: Proceed to Phase 5
   - If items fail: Update the spec (max 3 iterations)
   - If [NEEDS CLARIFICATION] markers remain: Present options to user

### Phase 5: Example Mapping

Transform abstract user stories into concrete, testable examples. This creates the foundation for Gherkin scenarios.

> 此階段整合了原 `/teammate.clarify` 的功能。不足時補最多 3 問，不中斷流程。

1. **For each User Story** (in priority order P1, P2, P3...):

   #### Step 1: Story Card
   - Extract the user story in As a / I want / So that format
   - Confirm the business value

   #### Step 2: Rules Discovery
   - Identify **business rules** that govern it:
     - What conditions must be true? What constraints exist?
     - What variations are allowed? What is NOT allowed? (principles boundaries)
   - For each rule: write a clear, testable statement; check against principles for conflicts

   #### Step 3: Examples Generation
   - For each rule, generate **concrete examples**:
     - At least one **happy path** example
     - At least one **alternative** example (if applicable)
     - At least one **negative/error** example
     - Consider **boundary conditions**
   - Each example follows Given/When/Then format

   #### Step 4: Questions Collection
   - Capture any **questions** that arise (ambiguous requirements, missing info, edge cases, principles conflicts)
   - For each question: state clearly, assess impact (High/Medium/Low), mark as Open or Resolved
   - **Inline Resolution**: 若有 High impact 問題，直接在此步驟中提出（最多 3 個），附帶建議選項讓使用者選擇。不中斷流程。

2. **Principles Boundary Check**: For each rule and example, verify against principles. Add explicit boundary examples.

3. **Generate Example Mapping Document**: Write to `FEATURE_DIR/example-mapping.md` using `.teammate/templates/example-mapping-template.md`

4. **Readiness Assessment**:

   | Metric | Current | Target | Status |
   |--------|---------|--------|--------|
   | Rules per story | [N] | 3+ | [Pass/Fail] |
   | Examples per rule | [Avg] | 2+ | [Pass/Fail] |
   | Open questions | [N] | 0 high-impact | [Pass/Fail] |
   | Principles boundaries | [N] | 1+ per story | [Pass/Fail] |

### Phase 6: Downstream Impact Check（Update Mode only）

若為 Update Mode 且 `FEATURE_DIR/plan.md` 已存在：

1. **比對 spec.md 修改內容與 plan.md**：
   - 新增/移除的 User Story → plan.md 的 scenarios + actions 需更新
   - 需求變更（FR 修改、Success Criteria 變更） → Architecture decisions 可能需調整
   - Example Mapping 新增 rules/examples → scenarios 可能需新增

2. **產出影響摘要**：
   ```
   ## Downstream Impact
   
   plan.md 狀態：[OUTDATED / UP-TO-DATE]
   
   受影響區域：
   - [N] User Stories 新增/修改 → scenarios 需更新
   - [N] FR 變更 → Architecture 可能需調整
   - [N] 新 rules → 可能需新增 scenarios
   
   建議：執行 `/teammate.plan update` 同步更新
   ```

3. **判斷規則**：
   - 有結構性變更（新增/移除 story、FR 修改） → 標記 `OUTDATED`，強烈建議 plan update
   - 僅 wording 修正（無結構變更） → 標記 `UP-TO-DATE`，plan.md 無需更新

> Create Mode 時跳過此步驟（plan.md 尚不存在）。

### Phase 7: Update Active Context（Memory Delta Protocol）

Update `.teammate/memory/progress.md` using delta mode:
- **覆寫 `## Current State`**：Active Feature: [name], Feature Branch: [branch], Phase: Align (complete), Last Command: align, Next Action: /teammate.plan
- **追加 `## Session Log`**：`| [timestamp] | align | Feature: [name], spec.md + example-mapping.md | [rules/examples count, open questions] |`
- **更新 `## Blockers`**：如有未解決的 high-impact questions，記錄為 blocker

### Phase 8: Report Completion

Output:
- Branch name
- Spec file path + Example Mapping file path
- Impact Mapping summary (Actors → Goals → Capabilities → Behaviors)
- Example Mapping summary (Stories → Rules → Examples → Questions)
- Readiness status for `/teammate.plan`
- Suggested next command: `/teammate.plan`

## Quick Guidelines

- Focus on **WHO** wants **WHAT** and **WHY**.
- Avoid HOW to implement (no tech stack, APIs, code structure).
- Written for business stakeholders, not developers.
- Each behavior must be observable and testable.
- Connect every feature to a business goal.

### Success Criteria Guidelines

Success criteria must be:
1. **Measurable**: Include specific metrics (time, percentage, count, rate)
2. **Technology-agnostic**: No mention of frameworks, languages, databases, or tools
3. **User-focused**: Describe outcomes from user/business perspective
4. **Verifiable**: Can be tested/validated without knowing implementation details

### Example Mapping Best Practices

**Good Rules**: "Users must be authenticated to access protected resources", "Orders cannot be modified after shipping"

**Bad Rules**: "The system should be secure" (too vague), "It must be fast" (no threshold)

**Principles Boundaries**: For each story, explicitly add examples showing what the system MUST NOT do.

## Behavior Rules

- If spec file already exists in Update Mode, preserve unchanged sections
- Never exceed 3 inline questions per session
- Respect user early termination signals ("stop", "done", "proceed")
- Always produce both spec.md and example-mapping.md (mark as draft if questions remain)
- Prioritize principles boundary examples for P1 stories
