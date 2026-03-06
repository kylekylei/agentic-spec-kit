---
name: design-system-setup
description: Initialize a design system with tokens, component patterns, and documentation through an 8-step interactive workflow. Use when setting up a new design system or reinitializing tokens.
---

# Design System Setup

Initialize a design system with design tokens, component patterns, and documentation. Creates a foundation for consistent UI development.

## Pre-flight Checks

1. Check if `.ui-design/` directory exists:
   - If exists with `design-system.json`: Ask to update or reinitialize
   - If not: Create `.ui-design/` directory

2. Detect existing design system indicators:
   - `tailwind.config.js` with custom theme
   - CSS custom properties in global styles
   - Existing token files (tokens.json, theme.ts, etc.)
   - Design system packages (chakra, radix, shadcn, etc.)

3. Load project context:
   - Detect styling approach (CSS, Tailwind, styled-components, etc.)
   - Detect TypeScript usage

4. If existing design system detected, offer: integrate / replace / view / cancel.

## Interactive Configuration (8 Questions)

Ask ONE question per turn. Wait for user response before proceeding.

### Q1: Design System Preset
1. **Minimal** — Colors, typography, spacing only
2. **Standard** — Colors, typography, spacing, shadows, borders, breakpoints
3. **Comprehensive** — Full token system with semantic naming, component tokens, animation, docs

### Q2: Brand Colors
Primary brand color (hex), then secondary/accent (or auto-generate).

### Q3: Color Mode Support
1. Light mode only
2. Dark mode only
3. Light and dark modes
4. Light, dark, and system preference

### Q4: Typography
System fonts / Inter / Open Sans / Roboto / Custom

### Q5: Spacing Scale
1. Linear (4px base)
2. Geometric (4px base, 1.5x multiplier)
3. Tailwind-compatible
4. Custom

### Q6: Border Radius
Sharp (0px) / Subtle (4px) / Moderate (8px) / Rounded (12px) / Pill (9999px)

### Q7: Output Format
1. CSS Custom Properties
2. Tailwind config extension
3. JavaScript/TypeScript module
4. JSON tokens (DTCG format)
5. Multiple formats

### Q8: Component Guidelines (Comprehensive only)
Generate guidelines for buttons, forms, cards, typography, icons — all, select, or none.

## Token Generation

Generate the following token sets based on user choices:

1. **Color Palette** — Primary (50-950), Secondary, Neutral, Semantic (success/warning/error/info)
2. **Typography Scale** — Font family, sizes (xs-5xl), weights, line heights
3. **Spacing Scale** — Based on chosen philosophy
4. **Additional Tokens** — Border radius, box shadow, breakpoints, animation (duration + easing)

## File Generation

### Output Files

```
.ui-design/
├── design-system.json          # Master configuration
├── tokens/
│   ├── tokens.css              # CSS custom properties (with dark mode)
│   ├── tailwind.config.js      # Tailwind extension
│   └── tokens.ts               # TypeScript module with type exports
├── docs/
│   └── design-system.md        # Documentation (comprehensive preset)
└── setup_state.json            # Setup state tracking
```

### Dark Mode

CSS custom properties include `@media (prefers-color-scheme: dark)` and `[data-theme="dark"]` selectors.

## Error Handling

- Conflicting config detected → offer merge strategies
- File write fails → report error, suggest manual creation
- Color generation fails → provide manual palette input
- Tailwind not detected → skip tailwind output, inform user
