---
description: Automatically generate Gherkin .feature files from spec.md and example-mapping.md, creating executable specifications.
handoffs: 
  - label: Define Tasks
    agent: teammate.tasks
    prompt: Create a technical plan with Screenplay Pattern for the feature
    send: true
  - label: Create Actions
    agent: teammate.actions
    prompt: Break down the feature into atomic verifiable actions
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

Goal: **Automatically** transform Example Mapping outputs into executable Gherkin `.feature` files. This is the core BDD artifact - the **Single Source of Truth** for system behavior.

**Mode**: This command runs in **automatic mode** - it generates complete .feature files without interactive confirmation, optimizing for quick iteration.

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Project context not initialized. Run `/teammate.kickoff` first."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern
   - If found ??**ERROR**: "Principles not defined. Run `/teammate.principles` first."

### Execution Steps

1. **Setup**: Run `.teammate/scripts/bash/check-prerequisites.sh --json --paths-only` from repo root. Parse JSON for:
   - `FEATURE_DIR`
   - `FEATURE_SPEC`
   - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot'

2. **Load Context**:
   
   Required files:
   - `FEATURE_DIR/spec.md` - User stories and requirements
   - `FEATURE_DIR/example-mapping.md` - Rules and examples
   - `.teammate/memory/principles.md` - Non-negotiable boundaries
   
   Optional files:
   - `.teammate/templates/feature-template.feature` - Gherkin template
   - `FEATURE_DIR/teammate.refs.yaml` - Context anchors (if exists)
   - `FEATURE_DIR/contracts/ui/design-principles.md` - UX 設計原則（if exists）
   - `.teammate/memory/project-context.md` - 後端 API 合約（for conflict scan）

3. **Create Features Directory**:
   
   ```bash
   mkdir -p FEATURE_DIR/scenarios
   ```

4. **UX Conflict Scan** (if `FEATURE_DIR/contracts/ui/design-principles.md` exists):

   在產生 scenarios 之前，強制執行設計原則衝突分析。

   #### 4a. 設計原則 vs 核心原則交叉比對
   
   For each design principle:
   - 是否需要後端 API 支援？→ 對照 `principles.md` Principle I（後端不可變）
   - 是否需要 SSE 事件中不存在的欄位？→ 對照 `project-context.md` API 合約
   - 是否需要新增後端 endpoint？→ 如是，標記 CONFLICT
   
   #### 4b. 互動元素可行性檢查
   
   For each design principle mentioning UI actions (buttons, links, gestures):
   - 該操作需要什麼後端能力？（取消、重試、刪除、查詢）
   - 後端 API 是否提供？（掃描 `project-context.md` REST APIs + SSE Streams）
   - 若不提供 → 標記 CONFLICT，建議替代方案
   
   #### 4c. 參考設計語意差異
   
   If design principles reference external products (e.g. "參考 Google Drive"):
   - 列出被參考的 UI 模式（佈局、互動、動畫）
   - 對每個互動操作，比較參考產品 vs 本專案的操作語意
   - 若語意不同（如「×」在 Google Drive = 取消上傳，但本系統無取消 API）→ 標記 SEMANTIC_GAP
   
   #### 4d. 產出 Conflict Report
   
   ```markdown
   ### UX Conflict Scan Results
   
   | 設計原則 | 衝突類型 | 說明 | 建議替代 |
   |----------|----------|------|----------|
   | III-1 重試按鈕 | CONFLICT | 後端無重試 API | 移除重試，改為「請重新上傳」提示 |
   | II-1 前往知識庫 | CONFLICT | SSE 不含 knowledge_id | 改為通用連結或移除 |
   | II-2 關閉按鈕 | SEMANTIC_GAP | Google Drive「×」=取消，本系統無取消 | 改為 dismiss（processing 時 disabled） |
   ```
   
   - 有 CONFLICT 或 SEMANTIC_GAP 時 → **暫停**，列出選項讓使用者決策
   - 使用者決策後，將結果更新到 `design-principles.md` 的「不做的事項」區段
   - 無衝突時 → 繼續產生 scenarios

5. **For Each User Story** (in priority order P1, P2, P3...):

   Generate a `.feature` file following this structure:

   #### Header
   ```gherkin
   @[feature-tag] @P[priority]
   Feature: [Story Title]
     As a [actor from spec]
     I want [capability from spec]
     So that [business value from spec]
   ```

   #### Background (if applicable)
   
   Extract common preconditions shared across all scenarios:
   ```gherkin
   Background:
     Given [common precondition from examples]
     And [another common precondition]
   ```

   #### Scenarios from Example Mapping

   For each **Rule** in example-mapping.md:
   - Convert each **Example** to a Scenario
   - Apply appropriate tags based on example type:
     - Happy path ??`@happy-path`
     - Alternative ??`@alternative`
     - Negative ??`@negative`
     - Boundary ??`@boundary`

   Transform example table rows:
   ```
   | Given (Context) | When (Action) | Then (Outcome) |
   ```
   
   Into Gherkin:
   ```gherkin
   @happy-path @P1
   Scenario: [Descriptive scenario name from rule + example]
     Given [context from example]
     When [action from example]
     Then [outcome from example]
   ```

   #### Principles Boundary Scenarios

   For each principles boundary in example-mapping.md:
   ```gherkin
   @principles @boundary @P1
   Scenario: System prevents [violation description]
     Given [context that could lead to violation]
     When [action that could violate principle]
     Then [system prevents violation]
     And [appropriate alternative behavior]
   ```

   #### Data-Driven Scenarios

   If multiple examples follow the same pattern, consolidate:
   ```gherkin
   @data-driven @P2
   Scenario Outline: [Pattern description]
     Given [context with "<variable>"]
     When [action with "<variable>"]
     Then [outcome with "<variable>"]

     Examples:
       | variable | expected |
       | value1   | result1  |
       | value2   | result2  |
   ```

6. **Write Feature Files**:

   For each user story, write to:
   `FEATURE_DIR/scenarios/[story-slug].feature`
   
   Naming convention:
   - `us1-user-authentication.feature`
   - `us2-password-reset.feature`
   - `us3-profile-management.feature`

7. **Generate Context Anchors**:

   Create or update `FEATURE_DIR/teammate.refs.yaml`:
   
   ```yaml
   # Behavior References for [Feature Name]
   # Auto-generated by /teammate.plan
   
   feature:
     name: [Feature Name]
     branch: [Branch Name]
     created: [Date]
   
   behaviors:
     - file: scenarios/us1-*.feature
       scenarios: [count]
       tags: [@P1, @happy-path, ...]
     
   principles:
     references:
       - principle: [Principle Name]
         scenarios: [List of @principles scenarios]
   
   dependencies:
     - [Other features this depends on]
   ```

8. **Coverage Validation**:

   Verify complete coverage:
   
   | Metric | Count | Status |
   |--------|-------|--------|
   | User Stories | [N] | |
   | Rules from Example Mapping | [N] | |
   | Scenarios Generated | [N] | |
   | Happy Path Coverage | [%] | |
   | Negative Path Coverage | [%] | |
   | Principles Boundaries | [N] | |
   
   **Coverage Requirements**:
   - Every rule must have at least one scenario
   - Every P1 story must have happy path + negative scenarios
   - Every principles boundary must have a scenario

9. **Gherkin Quality Check**:

   Validate generated scenarios:
   
   - [ ] Each scenario is independent (can run in isolation)
   - [ ] Steps are declarative (WHAT, not HOW)
   - [ ] No implementation details in steps
   - [ ] Scenario names are descriptive and unique
   - [ ] Tags follow convention (@P1/@P2/@P3, @happy-path, etc.)
   - [ ] Given/When/Then structure is correct
   - [ ] No "And" or "But" without preceding Given/When/Then

10. **Update Active Context**:

   Update `.teammate/memory/active-context.md`:
   - Mark `plan` as complete
   - List generated .feature files
   - Note coverage metrics
   - Set next action as `teammate.tasks`

11. **Report Completion**:

    Output:
    - List of generated .feature files with paths
    - Total scenarios generated
    - Coverage summary
    - Any gaps or warnings
    - Suggested next command: `/teammate.tasks`

## Gherkin Writing Guidelines

### Good Scenario Names
- "User successfully logs in with valid credentials"
- "System rejects login attempt with expired password"
- "Admin can view all user accounts"

### Bad Scenario Names
- "Test login" (too vague)
- "Login works" (not descriptive)
- "Scenario 1" (not meaningful)

### Step Writing Best Practices

**Given** - Context/State
- "Given the user is logged in"
- "Given the shopping cart contains 3 items"
- NOT: "Given I click the login button" (that's an action)

**When** - Action
- "When the user submits the form"
- "When the payment is processed"
- NOT: "When the button turns green" (that's an outcome)

**Then** - Outcome
- "Then the user sees a confirmation message"
- "Then the order status is 'Completed'"
- NOT: "Then click OK" (that's an action)

### Tag Convention

```gherkin
@feature-name @P1           # Feature and priority
@happy-path                  # Primary success path
@alternative                 # Valid alternative flows
@negative                    # Error/failure scenarios
@boundary                    # Edge cases and limits
@principles                # Principles boundary enforcement
@data-driven                 # Parameterized scenarios
@wip                        # Work in progress
@manual                      # Requires manual testing
```

## Automatic Mode Behavior

This command operates automatically:
- No confirmation prompts for each scenario
- Generates all .feature files in one pass
- Reports summary at completion
- User can review and edit generated files afterward

For interactive/guided mode, use `/teammate.clarify` first to refine examples.
