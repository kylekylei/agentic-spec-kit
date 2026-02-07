# Screenplay: [FEATURE_NAME]

**Feature Branch**: `[###-feature-name]`
**Created**: [DATE]
**Status**: Draft | Complete
**Feature Reference**: [Link to .feature file]

---

## Overview

> The Screenplay Pattern separates WHO (Actors) from WHAT (Tasks) from HOW (Abilities)

```
Actor → performs → Task → using → Ability → interacts with → System
```

---

## Actors

> Roles that interact with the system. Each actor represents a user persona or external system.

### Actor: [ACTOR_NAME]

**Description**: [Who this actor represents]
**Persona Reference**: [Link to persona in project-context.md if applicable]

**Abilities**:
- `[ABILITY_1]` — [What this ability allows]
- `[ABILITY_2]` — [What this ability allows]

**Goals**:
- [Primary goal this actor wants to achieve]
- [Secondary goal]

---

### Actor: [ACTOR_NAME_2]

**Description**: [Who this actor represents]

**Abilities**:
- `[ABILITY_1]` — [What this ability allows]

**Goals**:
- [Goal]

---

## Abilities

> Abstract capabilities that actors possess. Abilities are interfaces, not implementations.

### Ability: [ABILITY_NAME]

**Purpose**: [What this ability enables]
**Interface Type**: [UI/API/CLI/Event]

**Operations**:
| Operation | Input | Output | Notes |
|-----------|-------|--------|-------|
| [operation_name] | [Input type] | [Output type] | [Notes] |
| [operation_name] | [Input type] | [Output type] | [Notes] |

**Implementations**:
- [ ] Production: [e.g., BrowserAbility, RestApiAbility]
- [ ] Test: [e.g., MockApiAbility, TestBrowserAbility]

---

### Ability: [ABILITY_NAME_2]

**Purpose**: [What this ability enables]
**Interface Type**: [Type]

**Operations**:
| Operation | Input | Output | Notes |
|-----------|-------|--------|-------|
| [operation_name] | [Input type] | [Output type] | [Notes] |

---

## Tasks

> High-level goals that actors want to accomplish. Tasks orchestrate interactions.

### Task: [TASK_NAME]

**Actor**: [Which actor performs this]
**Goal**: [What the actor wants to achieve]
**Abilities Required**: `[ABILITY_1]`, `[ABILITY_2]`

**Preconditions**:
- [Condition that must be true before starting]

**Steps**:
1. [First interaction or sub-task]
2. [Second interaction]
3. [Third interaction]

**Postconditions**:
- [State that should be true after completion]

**Maps to Scenario**: [Scenario name from .feature file]

---

### Task: [TASK_NAME_2]

**Actor**: [Actor]
**Goal**: [Goal]
**Abilities Required**: `[ABILITY]`

**Preconditions**:
- [Condition]

**Steps**:
1. [Step]

**Postconditions**:
- [Condition]

**Maps to Scenario**: [Scenario name]

---

## Interactions

> Low-level actions that use abilities to interact with the system

### Interaction: [INTERACTION_NAME]

**Ability**: `[ABILITY_NAME]`
**Action**: [What this interaction does]

**Parameters**:
| Parameter | Type | Description |
|-----------|------|-------------|
| [param] | [Type] | [Description] |

**Returns**: [What the interaction returns]

---

## Interaction Map

> Visual representation of how components connect

```
┌─────────────────────────────────────────────────────────────────┐
│                         ACTORS                                   │
├─────────────────────────────────────────────────────────────────┤
│  [Actor1]                    [Actor2]                            │
│     │                           │                                │
│     ▼                           ▼                                │
├─────────────────────────────────────────────────────────────────┤
│                         TASKS                                    │
├─────────────────────────────────────────────────────────────────┤
│  [Task1]          [Task2]           [Task3]                      │
│     │                │                 │                         │
│     ▼                ▼                 ▼                         │
├─────────────────────────────────────────────────────────────────┤
│                       ABILITIES                                  │
├─────────────────────────────────────────────────────────────────┤
│  [Ability1]       [Ability2]        [Ability3]                   │
│     │                │                 │                         │
│     ▼                ▼                 ▼                         │
├─────────────────────────────────────────────────────────────────┤
│                        SYSTEM                                    │
├─────────────────────────────────────────────────────────────────┤
│  [UI]            [API]             [Database]                    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Traceability Matrix

> Maps scenarios to tasks to abilities

| Scenario (from .feature) | Task | Abilities Used | Status |
|--------------------------|------|----------------|--------|
| [Scenario name] | [Task name] | [Ability1, Ability2] | Draft/Implemented/Tested |
| [Scenario name] | [Task name] | [Ability] | [Status] |
| [Scenario name] | [Task name] | [Ability] | [Status] |

---

## Implementation Notes

### Step Definition Strategy

| Step Pattern | Task | Notes |
|--------------|------|-------|
| `Given [pattern]` | [Setup task] | [Notes] |
| `When [pattern]` | [Action task] | [Notes] |
| `Then [pattern]` | [Assertion task] | [Notes] |

### Technology Mapping

| Ability | Production Implementation | Test Implementation |
|---------|--------------------------|---------------------|
| [Ability] | [e.g., PlaywrightBrowser] | [e.g., MockBrowser] |
| [Ability] | [e.g., FetchApiClient] | [e.g., MockApiClient] |

---

## Checklist

- [ ] All actors identified from scenarios
- [ ] Each actor has defined abilities
- [ ] All tasks mapped to scenarios
- [ ] Abilities are abstract (no implementation details)
- [ ] Traceability matrix complete
- [ ] Ready for `/teammate.actions`

---

**Last Updated**: [DATE]
