# Project Context

## Project Identity

**Project Name**: [PROJECT_NAME]
**Description**: [Brief description of the project]
**Repository**: [Repository URL]

## Core Behaviors

> Define the primary behaviors that this product must exhibit. These are the observable, testable actions that deliver value.

- [BEHAVIOR_1]: [Description]
- [BEHAVIOR_2]: [Description]
- [BEHAVIOR_3]: [Description]

## Target Users

| Persona | Role | Primary Goals | Key Behaviors They Need |
|---------|------|---------------|------------------------|
| [PERSONA_1] | [Role] | [Goals] | [Behaviors] |
| [PERSONA_2] | [Role] | [Goals] | [Behaviors] |

## Business Goals

| Goal | Success Metric | Target | Priority |
|------|----------------|--------|----------|
| [GOAL_1] | [Metric] | [Target Value] | P1 |
| [GOAL_2] | [Metric] | [Target Value] | P2 |

## Technical Context

### Language & Framework

- **Primary Language**: [e.g., TypeScript, Python, Rust]
- **Framework**: [e.g., Next.js, FastAPI, Actix]
- **Runtime**: [e.g., Node.js 20, Python 3.11]

### Testing Stack

- **Unit Testing**: [e.g., Jest, pytest, cargo test]
- **Integration Testing**: [e.g., Playwright, pytest-integration]
- **BDD Framework**: [e.g., Cucumber, Behave, cucumber-rs]
- **Step Definition Language**: [e.g., TypeScript, Python]

### BDD Tools

- **Gherkin Parser**: [Tool name and version]
- **Living Documentation**: [e.g., Cucumber Reports, Allure]
- **Coverage Tracking**: [Tool or method]

## Architecture Patterns

### System Architecture

- **Pattern**: [e.g., Monolith, Microservices, Modular Monolith]
- **Communication**: [e.g., REST, gRPC, Event-driven]
- **Data Storage**: [e.g., PostgreSQL, MongoDB, SQLite]

### Code Organization

```text
[PROJECT_STRUCTURE]
```

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Features | kebab-case | `user-authentication.feature` |
| Scenarios | Sentence case | `User logs in with valid credentials` |
| Step Definitions | snake_case | `user_logs_in_with_valid_credentials` |
| Actors | PascalCase | `AuthenticatedUser` |
| Tasks | camelCase | `loginWithCredentials` |

## Integration Points

| System | Type | Protocol | Contract Location |
|--------|------|----------|-------------------|
| [SYSTEM_1] | [API/Event/File] | [REST/gRPC/Kafka] | [Path to contract] |

## Design References (Optional)

- **Design System**: [Name or N/A]
- **Design Tool**: [e.g., Pencil (.pen), Figma, or N/A]
- **Figma**: [URL or N/A]
- **Storybook**: [URL or N/A]

> Note: Feature-level Figma page links should be provided during `/speckit.plan` phase, not here.
> Design tool modifications (Pencil / Figma) are treated as implementation and must follow the Align → Plan → Execute workflow.

## Principles (Quick Reference)

> Full version: `.specify/memory/principles.md`

| # | Type | Rule |
|---|------|------|
| 1 | MUST | [PRINCIPLE_1] |
| 2 | MUST | [PRINCIPLE_2] |
| 3 | MUST NOT | [PRINCIPLE_3] |

## Aligned Contracts

> 跨系統 contract 版本追蹤。`/speckit.align` 更新此段落。

| Contract | Version | SHA / Package | Last Aligned |
|----------|---------|---------------|-------------|
| spec-contract | — | — | — |
| experience-contract | — | — | — |
| token-contract | @aiui/tokens@— | — | — |
| composition-recipes | — | — | — |

## Current

- **Foundation**: [complete/partial/missing]
- **Phase**: [init/align/plan/execute/review/idle]
- **Last**: [last completed action or milestone]
- **Next**: [next expected action]
- **Shipping Ceiling**: [L0–L{X} or —]

---

**Last Updated**: [DATE]
**Version**: 1.0.0
