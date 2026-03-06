---
name: component-scaffold
description: Guided 8-step interactive workflow for creating new UI components with proper patterns, accessibility, and styling. Use when a user asks to create, scaffold, or generate a new UI component.
---

# Component Scaffold

Guided workflow for creating new UI components following established patterns and best practices.

## Pre-flight Checks

1. Check if `.ui-design/` directory exists:
   - If not: Create `.ui-design/` directory
   - Create `.ui-design/components/` subdirectory for component tracking

2. Detect project configuration:
   - Scan for framework (React, Vue, Svelte, Angular)
   - Scan for styling approach (CSS Modules, Tailwind, styled-components, etc.)
   - Check for existing component patterns in `src/components/` or similar
   - Load `.ui-design/design-system.json` if exists

3. Load project context:
   - Check for `context.md` tech stack
   - Check for existing component conventions

4. If no framework detected, ask user to select one.

## Interactive Specification (8 Questions)

Ask ONE question per turn. Wait for user response before proceeding.

### Q1: Component Name
If not provided: ask for PascalCase name (e.g., UserCard, DataTable).

### Q2: Component Purpose
1. Display content (cards, lists, text blocks)
2. Collect input (forms, selects, toggles)
3. Navigation (menus, tabs, breadcrumbs)
4. Feedback (alerts, toasts, modals)
5. Layout (containers, grids, sections)
6. Data visualization (charts, graphs, indicators)
7. Other (describe)

### Q3: Component Complexity
1. Simple - Single responsibility, minimal props, no internal state
2. Compound - Multiple parts, some internal state, few props
3. Complex - Multiple subcomponents, state management, many props
4. Composite - Orchestrates other components, significant logic

### Q4: Props/Inputs Specification
For each prop: Name, Type, Required/Optional, Default value.

### Q5: State Requirements
1. Stateless - Pure presentational
2. Local state - Simple internal state
3. Controlled - State managed by parent
4. Uncontrolled - Manages own state
5. Hybrid - Both controlled and uncontrolled

### Q6: Composition Pattern (if complexity > Simple)
1. No children
2. Simple children
3. Named slots (header, body, footer)
4. Compound components (Card.Header, Card.Body)
5. Render props

### Q7: Accessibility Requirements
1. Basic - Semantic HTML, aria-labels
2. Keyboard navigation - Full keyboard support, focus management
3. Screen reader optimized - Live regions, announcements
4. Full WCAG AA - All applicable success criteria

### Q8: Styling Approach
Use detected approach or let user select (CSS Modules, Tailwind, Styled Components, etc.)

## Component Generation

### Directory Structure

```
{component_path}/
├── index.ts
├── {ComponentName}.tsx
├── {ComponentName}.test.tsx
├── {ComponentName}.styles.{ext}
└── types.ts
```

### Generated Files

1. **Main component** — with forwardRef, proper types, accessibility attributes
2. **Types** — TypeScript interface with JSDoc descriptions
3. **Styles** — based on chosen styling approach
4. **Tests** — render, variant, interaction, accessibility tests
5. **Barrel export** — index.ts with named exports

### Optional: Storybook Integration

If Storybook detected or requested, generate `{ComponentName}.stories.tsx` with Default, Primary, Secondary stories.

## User Review

After generating, offer:
1. Review generated code
2. Make modifications
3. Add more props or features
4. Generate Storybook stories
5. Done, keep as-is

## State Tracking

Create `.ui-design/components/{component_name}.json` with full specification and `files_created` list.

## Error Handling

- Component name conflicts → suggest alternatives, offer overwrite
- Directory creation fails → report error, suggest manual creation
- Framework not supported → provide generic template
- File write fails → save to temp location, provide recovery instructions
