---
description: Create or update the feature specification using Impact Mapping (WHO → WHY → HOW → WHAT) to identify valuable behaviors.
handoffs: 
  - label: Clarify with Examples
    agent: teammate.clarify
    prompt: Create example mappings for the spec. Let's identify rules and examples...
  - label: Create Work Plan
    agent: teammate.plan
    prompt: Generate Gherkin feature files from the spec and examples
    send: true
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

The text the user typed after `/teammate.align` in the triggering message **is** the feature description. Assume you always have it available in this conversation even if `$ARGUMENTS` appears literally below. Do not ask the user to repeat it unless they provided an empty command.

Given that feature description, execute the **Impact Mapping** workflow:

### Phase 0: Foundation Check

1. **Read `.teammate/memory/project-context.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern (e.g. `[PROJECT_NAME]`, `[BEHAVIOR_1]`)
   - If found → **ERROR**: "Project context not initialized. Run `/teammate.kickoff` first to set up your project identity, users, and goals."

2. **Read `.teammate/memory/principles.md`**
   - Scan for placeholder tokens matching `[ALL_CAPS_IDENTIFIER]` pattern (e.g. `[PRINCIPLE_1_NAME]`)
   - If found → **ERROR**: "Principles not defined. Run `/teammate.principles` first to define your non-negotiable boundaries."

3. **If both pass** → Load both files as working context for Impact Mapping:
   - project-context.md provides WHO (actors), WHY (business goals), and technical constraints
   - principles.md provides behavioral boundaries and invariants

### Phase 1: Setup

1. **Generate a concise short name** (2-4 words) for the branch:
   - Analyze the feature description and extract the most meaningful keywords
   - Create a 2-4 word short name that captures the essence of the feature
   - Use action-noun format when possible (e.g., "add-user-auth", "fix-payment-bug")
   - Preserve technical terms and acronyms (OAuth2, API, JWT, etc.)

2. **Check for existing branches before creating new one**:

   a. First, fetch all remote branches to ensure we have the latest information:
      ```bash
      git fetch --all --prune
      ```

   b. Find the highest feature number across all sources for the short-name:
      - Remote branches: `git ls-remote --heads origin | grep -E 'refs/heads/[0-9]+-<short-name>$'`
      - Local branches: `git branch | grep -E '^[* ]*[0-9]+-<short-name>$'`
      - Feature directories: Check for directories matching `features/[0-9]+-<short-name>`

   c. Determine the next available number:
      - Extract all numbers from all three sources
      - Find the highest number N
      - Use N+1 for the new branch number

   d. Run the script `.teammate/scripts/bash/create-new-feature.sh --json "$ARGUMENTS"` with the calculated number and short-name.
      - For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot")

### Phase 2: Impact Mapping

Execute the Impact Mapping framework to derive valuable behaviors:

#### WHO (Actors)

1. **Identify all actors** who will interact with this feature:
   - Primary users (who directly benefits)
   - Secondary users (who uses the output)
   - System actors (external systems, AI agents)
   - Administrative actors (who manages/configures)

2. For each actor, define:
   - Role name
   - Primary goals
   - Current pain points

#### WHY (Business Goals)

3. **Define the business impact** this feature should create:
   - What business outcome does this enable?
   - How will we measure success?
   - What happens if we don't build this?

4. Connect each actor to business goals:
   - How does each actor contribute to the goal?
   - What behavior change do we need from them?

#### HOW (Capabilities)

5. **Identify capabilities** needed to achieve the goals:
   - What must actors be able to do?
   - What new behaviors are we enabling?
   - What existing behaviors are we improving?

#### WHAT (Features/Behaviors)

6. **Derive concrete behaviors** from capabilities:
   - Each behavior must be observable
   - Each behavior must be testable
   - Each behavior must deliver value independently

### Phase 3: Specification

3. Load `.teammate/templates/spec-template.md` to understand required sections.

4. **Fill the specification** following this execution flow:

    1. Parse user description from Input
       If empty: ERROR "No feature description provided"
    2. Map Impact Mapping results to User Stories:
       - Each capability → one or more user stories
       - Each actor → As a [actor]
       - Each business goal → So that [goal]
       - Each behavior → I want [behavior]
    3. For unclear aspects:
       - Make informed guesses based on context and industry standards
       - Only mark with [NEEDS CLARIFICATION: specific question] if:
         - The choice significantly impacts feature scope or user experience
         - Multiple reasonable interpretations exist with different implications
         - No reasonable default exists
       - **LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total**
    4. Fill User Scenarios & Testing section
       - Prioritize by business value (P1 = highest value)
       - Each story independently testable
    5. Generate Functional Requirements
       - Each requirement must be testable
       - Map to behaviors identified in Impact Mapping
    6. Define Success Criteria
       - Create measurable, technology-agnostic outcomes
       - Connect to WHY (business goals)
    7. Identify Key Entities (if data involved)
    8. Return: SUCCESS (spec ready for example mapping)

5. Write the specification to SPEC_FILE using the template structure.

### Phase 4: Validation

6. **Specification Quality Validation**: After writing the initial spec, validate it:

   a. **Create Spec Quality Checklist**: Generate a checklist file at `FEATURE_DIR/checklists/requirements.md`
   
   b. **Validate** against criteria:
      - No implementation details (languages, frameworks, APIs)
      - Focused on user value and business needs
      - Written for non-technical stakeholders
      - All mandatory sections completed
      - Requirements are testable and unambiguous
      - Success criteria are measurable and technology-agnostic

   c. **Handle Validation Results**:
      - If all items pass: Proceed to step 7
      - If items fail: Update the spec to address issues (max 3 iterations)
      - If [NEEDS CLARIFICATION] markers remain: Present options to user

7. **Update Active Context**:
   Update `.teammate/memory/active-context.md`:
   - Mark `align` as complete
   - Record the feature short name and branch
   - Set next action as `teammate.clarify`

8. Report completion with:
   - Branch name
   - Spec file path
   - Impact Mapping summary (Actors → Goals → Capabilities → Behaviors)
   - Checklist results
   - Readiness for `/teammate.clarify`

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

**Good examples**:
- "Users can complete checkout in under 3 minutes"
- "System supports 10,000 concurrent users"
- "95% of searches return results in under 1 second"

**Bad examples** (implementation-focused):
- "API response time is under 200ms"
- "Database can handle 1000 TPS"
- "React components render efficiently"
