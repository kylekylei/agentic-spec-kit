---
description: "Actions template for feature implementation - atomic verifiable actions"
---

# Actions: [FEATURE NAME]

**Input**: Design documents from `/features/[###-feature-name]/`
**Prerequisites**: spec.md, example-mapping.md, scenarios/*.feature, screenplay.md, tasks.md

**BDD Integration**: Each action MUST reference the scenario(s) it verifies via the `[Verifies: @tag]` marker.

**Organization**: Actions are grouped by user story and linked to Gherkin scenarios for full traceability.

## Format: `[ActionID] [P?] [Story?] [Verifies: @scenario-tag] Description`

- **[ActionID]**: Sequential ID (S001, S002, S003...)
- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this action belongs to (e.g., US1, US2, US3)
- **[Verifies: @tag]**: Links to scenario tag(s) in .feature files
- Include exact file paths in descriptions

## Path Conventions

- **Single project**: `src/`, `tests/` at repository root
- **Web app**: `backend/src/`, `frontend/src/`
- **Mobile**: `api/src/`, `ios/src/` or `android/src/`
- Paths shown below assume single project - adjust based on tasks.md structure

<!-- 
  ============================================================================
  ATOMIC VERIFIABLE ACTIONS
  
  The /teammate.actions command MUST replace these with actual actions based on:
  - Scenarios from scenarios/*.feature (with their priority tags @P1, @P2, @P3)
  - User stories from spec.md
  - Actors/Tasks from screenplay.md
  - Technical structure from tasks.md
  
  Each action:
  - Links to one or more Gherkin scenarios via [Verifies: @tag]
  - Can be implemented and verified independently
  - Forms a traceable chain from behavior to implementation
  
  DO NOT keep these sample actions in the generated actions.md file.
  ============================================================================
-->

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure
**Verifies**: Foundation for all scenarios

- [ ] S001 [Verifies: @setup] Create project structure per implementation plan
- [ ] S002 [Verifies: @setup] Initialize [language] project with [framework] dependencies
- [ ] S003 [P] [Verifies: @setup] Configure linting and formatting tools

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

Examples of foundational actions (adjust based on your project):

- [ ] S004 [Verifies: @foundation] Setup database schema and migrations framework
- [ ] S005 [P] [Verifies: @foundation] Implement authentication/authorization framework
- [ ] S006 [P] [Verifies: @foundation] Setup API routing and middleware structure
- [ ] S007 [Verifies: @foundation] Create base models/entities that all stories depend on
- [ ] S008 [Verifies: @foundation] Configure error handling and logging infrastructure
- [ ] S009 [Verifies: @foundation] Setup environment configuration management

**Checkpoint**: Foundation ready - user story implementation can now begin in parallel

---

## Phase 3: User Story 1 - [Title] (Priority: P1) 🎯 MVP

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Step Definitions for User Story 1

> **RED-GREEN LOOP: Write step definitions FIRST, ensure they FAIL before implementation**

- [ ] S010 [P] [US1] [Verifies: @us1-happy-path] Step definitions for happy path scenario
- [ ] S011 [P] [US1] [Verifies: @us1-negative] Step definitions for negative scenario

### Implementation for User Story 1

- [ ] S012 [P] [US1] [Verifies: @us1-happy-path] Create [Entity1] model in src/models/[entity1].py
- [ ] S013 [P] [US1] [Verifies: @us1-happy-path] Create [Entity2] model in src/models/[entity2].py
- [ ] S014 [US1] [Verifies: @us1-happy-path] Implement [Service] in src/services/[service].py (depends on S012, S013)
- [ ] S015 [US1] [Verifies: @us1-happy-path, @us1-alternative] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] S016 [US1] [Verifies: @us1-negative] Add validation and error handling
- [ ] S017 [US1] [Verifies: @us1-boundary] Add logging for user story 1 operations

**Checkpoint**: At this point, User Story 1 should be fully functional and testable independently

---

## Phase 4: User Story 2 - [Title] (Priority: P2)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Step Definitions for User Story 2

- [ ] S018 [P] [US2] [Verifies: @us2-happy-path] Step definitions for happy path scenario
- [ ] S019 [P] [US2] [Verifies: @us2-negative] Step definitions for negative scenario

### Implementation for User Story 2

- [ ] S020 [P] [US2] [Verifies: @us2-happy-path] Create [Entity] model in src/models/[entity].py
- [ ] S021 [US2] [Verifies: @us2-happy-path] Implement [Service] in src/services/[service].py
- [ ] S022 [US2] [Verifies: @us2-happy-path, @us2-alternative] Implement [endpoint/feature] in src/[location]/[file].py
- [ ] S023 [US2] [Verifies: @us2-integration] Integrate with User Story 1 components (if needed)

**Checkpoint**: At this point, User Stories 1 AND 2 should both work independently

---

## Phase 5: User Story 3 - [Title] (Priority: P3)

**Goal**: [Brief description of what this story delivers]

**Independent Test**: [How to verify this story works on its own]

### Step Definitions for User Story 3

- [ ] S024 [P] [US3] [Verifies: @us3-happy-path] Step definitions for happy path scenario
- [ ] S025 [P] [US3] [Verifies: @us3-negative] Step definitions for negative scenario

### Implementation for User Story 3

- [ ] S026 [P] [US3] [Verifies: @us3-happy-path] Create [Entity] model in src/models/[entity].py
- [ ] S027 [US3] [Verifies: @us3-happy-path] Implement [Service] in src/services/[service].py
- [ ] S028 [US3] [Verifies: @us3-happy-path, @us3-alternative] Implement [endpoint/feature] in src/[location]/[file].py

**Checkpoint**: All user stories should now be independently functional

---

[Add more user story phases as needed, following the same pattern]

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories
**Verifies**: @polish, @cross-cutting

- [ ] SXXX [P] [Verifies: @documentation] Documentation updates in docs/
- [ ] SXXX [Verifies: @refactor] Code cleanup and refactoring
- [ ] SXXX [Verifies: @performance] Performance optimization across all stories
- [ ] SXXX [P] [Verifies: @coverage] Additional unit tests in tests/unit/
- [ ] SXXX [Verifies: @security] Security hardening
- [ ] SXXX [Verifies: @validation] Run quickstart.md validation

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies - can start immediately
- **Foundational (Phase 2)**: Depends on Setup completion - BLOCKS all user stories
- **User Stories (Phase 3+)**: All depend on Foundational phase completion
  - User stories can then proceed in parallel (if staffed)
  - Or sequentially in priority order (P1 → P2 → P3)
- **Polish (Final Phase)**: Depends on all desired user stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Can start after Foundational (Phase 2) - No dependencies on other stories
- **User Story 2 (P2)**: Can start after Foundational (Phase 2) - May integrate with US1 but should be independently testable
- **User Story 3 (P3)**: Can start after Foundational (Phase 2) - May integrate with US1/US2 but should be independently testable

### Within Each User Story (Red-Green Loop)

- Step definitions MUST be written FIRST and FAIL (RED)
- Implement minimum code to pass (GREEN)
- Refactor if needed
- Models before services
- Services before endpoints
- Core implementation before integration
- All scenario tags verified before marking story complete

### Parallel Opportunities

- All Setup tasks marked [P] can run in parallel
- All Foundational tasks marked [P] can run in parallel (within Phase 2)
- Once Foundational phase completes, all user stories can start in parallel (if team capacity allows)
- All tests for a user story marked [P] can run in parallel
- Models within a story marked [P] can run in parallel
- Different user stories can be worked on in parallel by different team members

---

## Parallel Example: User Story 1

```bash
# Launch all tests for User Story 1 together (if tests requested):
Task: "Contract test for [endpoint] in tests/contract/test_[name].py"
Task: "Integration test for [user journey] in tests/integration/test_[name].py"

# Launch all models for User Story 1 together:
Task: "Create [Entity1] model in src/models/[entity1].py"
Task: "Create [Entity2] model in src/models/[entity2].py"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL - blocks all stories)
3. Complete Phase 3: User Story 1
4. **STOP and VALIDATE**: Test User Story 1 independently
5. Deploy/demo if ready

### Incremental Delivery

1. Complete Setup + Foundational → Foundation ready
2. Add User Story 1 → Test independently → Deploy/Demo (MVP!)
3. Add User Story 2 → Test independently → Deploy/Demo
4. Add User Story 3 → Test independently → Deploy/Demo
5. Each story adds value without breaking previous stories

### Parallel Team Strategy

With multiple developers:

1. Team completes Setup + Foundational together
2. Once Foundational is done:
   - Developer A: User Story 1
   - Developer B: User Story 2
   - Developer C: User Story 3
3. Stories complete and integrate independently

---

## Notes

- [P] actions = different files, no dependencies
- [Story] label maps action to specific user story for traceability
- [Verifies: @tag] links action to Gherkin scenario(s) for behavior traceability
- Each user story should be independently completable and testable
- RED-GREEN LOOP: Step definitions fail (RED) → Implement → Pass (GREEN)
- Commit after each action or logical group
- Stop at any checkpoint to validate story independently
- Avoid: vague actions, same file conflicts, missing scenario links

---

## Traceability Matrix

> Auto-generated summary linking actions to scenarios

| Scenario Tag | Actions | Status |
|--------------|---------|--------|
| @us1-happy-path | S010, S012-S015 | Pending |
| @us1-negative | S011, S016 | Pending |
| @us2-happy-path | S018, S020-S022 | Pending |
| @us3-happy-path | S024, S026-S028 | Pending |

**Coverage**: [X]/[Y] scenarios have linked actions ([Z]%)
