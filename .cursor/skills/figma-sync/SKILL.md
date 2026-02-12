---
name: figma-sync
description: Sync implemented UI components to Figma via cursor-talk-to-figma-mcp — creates visual specs, state variants, and design documentation. Use when the user asks to write UI components into Figma, create Figma specs from code, or sync implementation to Figma designs.
---

# Figma Sync

Sync implemented UI components into Figma, creating visual spec frames with state variants, annotations, and design tokens. Uses `cursor-talk-to-figma-mcp` write tools.

## Trigger Condition

Activate when:
- User asks to "write to Figma", "sync to Figma", or "create Figma specs"
- User provides a Figma channel name and target node ID
- User wants to document implemented UI as Figma frames

## Prerequisites

1. **Figma Desktop** is open with **Cursor Talk To Figma** plugin running
2. User provides **channel name** (shown in plugin)
3. User provides **target node ID** (from Figma URL `node-id` parameter)

## Argument Parsing

| Pattern | Behavior |
|---------|----------|
| `[channel] [nodeId]` | Join channel, create designs in target node |
| `[channel] [nodeId] [component]` | Only generate the specified component |
| `[figma-url]` | Extract nodeId from URL (`?node-id=79-98` → `79:98`) |

## Execution Steps

### Step 0: Connect to Figma

1. Call `join_channel(channel)`
2. Call `get_document_info()` to verify connection
3. If connection fails → **ERROR**: Prompt user to verify plugin is running

### Step 1: Load Design Context

Required:
- `contracts/ui/` — Component specs, props, styles (from `/teammate.plan`)
- `principles.md` — Design system reference (color tokens, border-radius, spacing)
- Component source code (`.svelte`, `.tsx`, `.vue`) — Infer UI structure

Optional:
- `spec.md` — User scenario descriptions
- `plan.md` — Visual descriptions from technical plan (Part 1: Architecture)

### Step 2: Determine Scope

If specific component name provided → only that component.
Otherwise → scan `contracts/ui/` for all components marked `[NEW]` or `[ENHANCE]`.

For each component, identify:
- **States**: Infer from conditional rendering (`{#if}`, ternary, `v-if`, etc.)
- **Props variants**: Infer from exported props/interface
- **Responsive**: Detect compact/full modes

### Step 3: Prepare Target Frame

1. Call `get_node_info(nodeId)` to check target frame
2. If frame is empty → use directly
3. If frame has content → ask user: "Append or replace?"

### Step 4: Create Design for Each Component

For each component:

#### 4a. Frame Structure

```
[Component Title]
├── [State: Default]         ← Primary state, full frame
├── [State: Variant 1]       ← Additional state variants
├── [State: Variant N]
├── [Tokens & Specs]         ← Color, spacing, border-radius text
└── [Behavior Notes]         ← Interaction behavior annotations
```

#### 4b. Build State Frames

Use TalkToFigma tools:

| Tool | Purpose |
|------|---------|
| `create_frame` | Container with auto-layout, padding, spacing |
| `create_text` | Labels, content, spec annotations |
| `create_rectangle` | Color blocks, progress bars, dividers |
| `set_fill_color` | Background/fill color |
| `set_stroke_color` | Border color |
| `set_corner_radius` | Border radius |
| `set_layout_mode` | Auto-layout (HORIZONTAL / VERTICAL) |
| `set_padding` | Padding |
| `set_item_spacing` | Item spacing |
| `set_layout_sizing` | FILL / HUG / FIXED |

#### 4c. Color Mapping

Map design tokens from `principles.md` or project design system to Figma RGB (0-1 scale). Read the project's color token definitions and convert accordingly.

#### 4d. Annotations

For each component section, add text annotations:
- **Specs**: Dimensions, border-radius, borders, shadows
- **Behavior**: Animations, timing, conditional rendering
- **Props**: Key props and default values
- **Mount point**: Where in the app this component lives

### Step 5: Add Overview

At the top of the target frame:
- Feature name
- Component list
- Design language summary (referencing design system)

### Step 6: Report

Output:
- Components created with state counts
- Figma node IDs for reference
- Suggestion: update `contracts/ui/` with Figma links

## Design Principles

1. **Auto-layout first** — All frames use auto-layout, no manual positioning
2. **Tokens over hardcode** — Colors use project token values, no custom hex
3. **State completeness** — Each component shows all visible states (default, error, empty, loading; hover optional)
4. **Light mode only** — Show light mode in Figma; annotate dark mode color mappings as text
5. **Annotate behavior** — Dynamic behavior (fade, transition, timer) described as text annotations

## Key Rules

- **Read implementation first** — Infer UI structure from actual source code, never design from scratch
- **Faithful to code** — Figma design must reflect implemented code, not idealized mockups
- **Annotate what Figma can't show** — Animations, real-time updates, conditional rendering
- **One frame per component** — Each component gets an independent section frame
- **Channel must be active** — Verify Figma plugin connection before every operation

## Cross-Reference

This skill integrates with:
- `contracts/ui/` — UI component specifications (from `/teammate.plan`)
- `principles.md` — Design system token reference
- `figma-design-audit` skill — Audit Figma designs for structural readiness (reverse direction)
