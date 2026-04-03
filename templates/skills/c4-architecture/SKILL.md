---
name: c4-architecture
description: Generate comprehensive C4 architecture documentation (Context, Container, Component, Code) for an existing codebase using bottom-up analysis. Use when documenting system architecture or creating architectural diagrams.
---

# C4 Architecture Documentation

Generate comprehensive C4 architecture documentation following the [official C4 model](https://c4model.com/diagrams) using a bottom-up analysis approach.

## Overview

This workflow creates documentation at all four C4 levels:

1. **Code Level**: Analyzing every subdirectory bottom-up to create code-level documentation
2. **Component Level**: Synthesizing code documentation into logical components within containers
3. **Container Level**: Mapping components to deployment containers with API documentation
4. **Context Level**: Creating high-level system context with personas and user journeys

All documentation is written to a new `C4-Documentation/` directory in the repository root.

## Phase 1: Code-Level Documentation (Bottom-Up)

### 1.1 Discover All Subdirectories

- Identify all subdirectories, sorted by depth (deepest first)
- Filter out non-code directories (node_modules, .git, build, dist, etc.)

### 1.2 Process Each Directory

For each directory (deepest first), create `c4-code-[directory-name].md` with:

1. **Overview**: Name, Description, Location, Language, Purpose
2. **Code Elements**: All functions/methods with complete signatures, all classes/modules
3. **Dependencies**: Internal and external
4. **Relationships**: Mermaid diagram if complex

## Phase 2: Component-Level Synthesis

### 2.1 Identify Component Boundaries

Analyze code-level docs for logical groupings by domain, technical, and organizational boundaries.

### 2.2 Create Component Documentation

For each component, create `c4-component-[name].md` with:

1. **Overview**: Name, Description, Type, Technology
2. **Purpose**: Detailed description, problems solved, role in system
3. **Software Features**: All features provided
4. **Code Elements**: Links to contained c4-code files
5. **Interfaces**: Name, Protocol, Description, Operations
6. **Dependencies**: Components used, external systems
7. **Component Diagram**: Mermaid diagram

### 2.3 Master Component Index

Create `c4-component.md` with list of all components and relationship diagram.

## Phase 3: Container-Level Synthesis

### 3.1 Analyze Deployment Definitions

Search for Dockerfiles, K8s manifests, Docker Compose, Terraform, CI/CD configs.

### 3.2 Map Components to Containers

Create `c4-container.md` with:

1. **Containers**: Name, Description, Type, Technology, Deployment
2. **Components**: List per container with links
3. **Interfaces**: APIs with protocol and endpoints
4. **API Specifications**: OpenAPI 3.1+ specs in `apis/` subdirectory
5. **Dependencies**: Inter-container and external
6. **Infrastructure**: Deployment config, scaling, resources
7. **Container Diagram**: Mermaid diagram

## Phase 4: Context-Level Documentation

Create `c4-context.md` with:

1. **System Overview**: Short and long descriptions
2. **Personas**: Human users, programmatic users, external systems with goals
3. **System Features**: High-level features with persona mapping
4. **User Journeys**: Step-by-step journeys per feature per persona
5. **External Systems**: Dependencies with integration type
6. **System Context Diagram**: Mermaid C4Context diagram
7. **Related Documentation**: Links to container and component docs

## Output Structure

```
C4-Documentation/
├── c4-code-*.md
├── c4-component-*.md
├── c4-component.md
├── c4-container.md
├── c4-context.md
└── apis/
    └── [container]-api.yaml
```

## Success Criteria

- Every subdirectory has a corresponding c4-code file
- Components are logically grouped with clear boundaries
- Containers map to actual deployment units
- All container APIs documented with OpenAPI specs
- System context includes all personas and user journeys
- All external systems and dependencies identified
- Documentation is organized in C4-Documentation/ directory
