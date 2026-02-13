---
name: figma-design-audit
description: Reverse-audit Figma design files via Dev Mode links to verify structural readiness for AI-driven code generation. Use when reviewing Figma dev links (e.g., from designInventory.md) to check if the design follows data-first principles — variables, auto layout, semantic naming, component architecture, and file hygiene. Explicitly flags unclear design intent.
---

# Figma Design Audit

Reverse-audit a Figma design file (via Dev Mode link or node reference) to verify it follows **structured data construction** principles. AI agents read structure, not visuals — this skill ensures the design file is machine-readable.

## Trigger Condition

Activate when:
- User provides or selects a Figma dev link (e.g., `figma.com/design/...?node-id=...&m=dev`)
- User references a node from `.teammate/design/figma-index.md`
- User requests Figma design review or readiness check
- Pre-implementation design quality gate is needed

## Audit Protocol

Execute **all 5 checks** sequentially against the Figma node data (retrieved via Figma MCP or API). Report each finding with severity level.

---

### Check 1: Variables Compliance (數值變數化)

**Principle:** All values MUST be variables. Raw values are prohibited.

**Inspect:**
- Font sizes, line heights — bound to Typography variables?
- Spacing (Gap / Padding) — bound to Spacing variables?
- Border radius — bound to Radius variables?
- Colors — bound to Color variables?
- Widths / Heights (non-auto) — bound to Size variables?

**Severity Levels:**

| Finding | Severity | Example |
|---------|----------|---------|
| Raw hex color detected | `CRITICAL` | `fill: #007AFF` instead of `color-bg-primary` |
| Hard-coded spacing | `CRITICAL` | `padding: 16` instead of `spacing-md` |
| Raw font size | `HIGH` | `fontSize: 14` instead of `text-body-sm` |
| Raw border radius | `MEDIUM` | `borderRadius: 8` instead of `radius-md` |
| Fixed dimension without variable | `LOW` | `width: 320` (may be intentional) |

**Token Architecture Check:**
- Verify Primitive -> Semantic layering exists
  - `PASS`: `color-bg-primary` (semantic) -> `blue-600` (primitive) -> `#2563EB` (raw)
  - `FAIL`: Component directly uses `#2563EB` or `blue-600`
- Check if Variable Modes are defined (light/dark, brand variants)

**Unclear Intent Flag:**
> If variables exist but naming is inconsistent or non-semantic (e.g., `color-1`, `size-a`), flag:
> `UNCLEAR INTENT: Variables detected but naming lacks semantic meaning. Cannot determine design system mapping. Please clarify token naming convention.`

---

### Check 2: Auto Layout Compliance (自動佈局)

**Principle:** Auto Layout is the ONLY way AI understands layout logic.

**Inspect:**
- Every frame/container uses Auto Layout?
- Direction (horizontal/vertical) explicitly set?
- Resize behavior (`Hug` / `Fill` / `Fixed`) defined for all children?
- No absolute positioning unless justified (badges, overlays)?

**Severity Levels:**

| Finding | Severity | Example |
|---------|----------|---------|
| Top-level frame without Auto Layout | `CRITICAL` | Page container is a plain Frame |
| Nested container without Auto Layout | `HIGH` | Card body is manually positioned |
| Absolute positioning without justification | `HIGH` | Button group uses absolute coords |
| Ambiguous resize behavior | `MEDIUM` | Child is `Fixed` but context suggests `Fill` |
| Missing gap/spacing definition | `MEDIUM` | Children visually spaced but no gap set |

**Flexbox Mapping Check:**
- Verify Auto Layout properties map cleanly to CSS Flexbox:
  - `direction` -> `flex-direction`
  - `gap` -> `gap`
  - `padding` -> `padding`
  - `primaryAxisAlignment` -> `justify-content`
  - `counterAxisAlignment` -> `align-items`
  - Children `layoutAlign` -> `align-self`

**Responsive Behavior Check:**
- `Hug` -> content-driven sizing (good for text, icons)
- `Fill` -> container-driven sizing (good for responsive columns)
- `Fixed` -> explicit dimension (flag unless intentional)

**Unclear Intent Flag:**
> If a frame mixes Auto Layout children with absolute-positioned children without Dev Mode annotation explaining why:
> `UNCLEAR INTENT: Frame contains both Auto Layout and absolute-positioned children. Cannot determine intended responsive behavior. Please add Dev Mode annotation or restructure.`

---

### Check 3: Component Architecture (元件架構)

**Principle:** Use Variants for states, Component Properties for API, Slots for composition.

**Inspect:**
- Interactive elements (buttons, inputs, cards) are Component Instances?
- States (Default / Hover / Active / Disabled / Focus) defined as Variants?
- Boolean properties used for show/hide toggles?
- Text properties used for content overrides?
- No Detached Instances?

**Severity Levels:**

| Finding | Severity | Example |
|---------|----------|---------|
| Detached Instance detected | `CRITICAL` | Button was detached — AI sees raw shapes |
| Interactive element is plain Frame | `CRITICAL` | Submit button is a styled rectangle |
| Missing state variants | `HIGH` | Button has Default only, no Hover/Disabled |
| No Component Properties | `MEDIUM` | Icon visibility toggled by hiding layer |
| Missing Slot structure | `LOW` | Modal content area is fixed, not composable |

**Slot Pattern Check:**
- Complex components (Modal, Card, Dialog) should contain placeholder/slot frames
- These map to React `children` / `slots` props

**Unclear Intent Flag:**
> If a component has multiple visual variations but they are separate components (not variants of one):
> `UNCLEAR INTENT: Found multiple similar components (e.g., ButtonBlue, ButtonGreen) that appear to be variants of the same base. Cannot determine if these are intentionally separate components or should be unified. Please clarify.`

---

### Check 4: Naming & Hierarchy (命名與層級)

**Principle:** Name layers like code — semantic, functional, no defaults.

**Inspect:**
- No default names (`Frame 1`, `Rectangle 12`, `Group 5`)?
- Names follow functional/semantic convention (`SubmitButton`, `MainContainer`, `ProfileCard`)?
- Component naming uses `/` grouping (`Button/Primary/Default`)?
- Layer hierarchy reflects DOM structure?

**Severity Levels:**

| Finding | Severity | Example |
|---------|----------|---------|
| Default Figma name on visible layer | `HIGH` | `Frame 428` as main content area |
| Ambiguous generic name | `MEDIUM` | `Container` (which container?) |
| Missing `/` grouping in components | `LOW` | `PrimaryButton` instead of `Button/Primary` |
| Layer order doesn't match visual order | `LOW` | First visual element is last in layer tree |

**Naming Pattern Validation:**
- Acceptable: `NavContainer`, `HeroSection`, `OptionButton/Default`
- Unacceptable: `Frame 12`, `Rectangle 5`, `Group 3`
- Check for naming consistency across same-type elements

**Unclear Intent Flag:**
> If names exist but mix conventions (e.g., camelCase + kebab-case + Chinese):
> `UNCLEAR INTENT: Layer naming uses inconsistent conventions. Found: camelCase ("submitBtn"), kebab-case ("submit-btn"), Chinese ("提交按鈕"). Cannot determine canonical naming pattern for code generation. Please standardize.`

---

### Check 5: File Hygiene & Dev Annotations (檔案清理與開發註釋)

**Principle:** Give AI clean context. Annotate what visuals cannot express.

**Inspect:**
- No hidden layers that contain outdated/experimental content?
- No unused components on the canvas?
- Dev Mode annotations present for interaction behaviors?
- ARIA label hints or accessibility notes provided?

**Severity Levels:**

| Finding | Severity | Example |
|---------|----------|---------|
| Hidden layer with content that conflicts with visible layers | `HIGH` | Old button design hidden but still present |
| No Dev Mode annotations on interactive elements | `MEDIUM` | Click behavior undocumented |
| Missing accessibility annotations | `MEDIUM` | No ARIA hints for screen readers |
| Experimental/WIP frames on same page | `LOW` | "v2 exploration" frame near production frame |

**Annotation Checklist:**
- [ ] Click/tap behaviors described
- [ ] Navigation flows annotated
- [ ] Loading/empty/error states documented
- [ ] ARIA labels specified for non-obvious elements
- [ ] Animation/transition intent noted

**Unclear Intent Flag:**
> If interactive elements have no annotations and behavior cannot be inferred from context:
> `UNCLEAR INTENT: Interactive element detected (appears clickable) but no Dev Mode annotation describes the expected behavior. AI cannot generate interaction logic without this context. Please add annotation.`

---

## Audit Output Format

```
============================================
  FIGMA DESIGN AUDIT REPORT
  Node: [node-name] ([node-id])
  File: [figma-file-name]
  Date: [YYYY-MM-DD]
============================================

## Summary
| Check | Status | Critical | High | Medium | Low |
|-------|--------|----------|------|--------|-----|
| 1. Variables    | PASS/FAIL | 0 | 0 | 0 | 0 |
| 2. Auto Layout  | PASS/FAIL | 0 | 0 | 0 | 0 |
| 3. Components   | PASS/FAIL | 0 | 0 | 0 | 0 |
| 4. Naming       | PASS/FAIL | 0 | 0 | 0 | 0 |
| 5. Hygiene      | PASS/FAIL | 0 | 0 | 0 | 0 |

Overall: [READY / NOT READY / NEEDS CLARIFICATION]

## Unclear Intent Flags
[List all UNCLEAR INTENT items — these MUST be resolved before implementation]

## Detailed Findings
[Per-check breakdown with specific layer paths and recommendations]

## Recommendations
[Prioritized action items for the designer]
```

## Readiness Verdict

| Verdict | Condition |
|---------|-----------|
| `READY` | 0 Critical, 0 High, 0 Unclear Intent flags |
| `CONDITIONAL` | 0 Critical, <=2 High (with workarounds noted), 0 Unclear Intent |
| `NOT READY` | Any Critical findings |
| `NEEDS CLARIFICATION` | Any Unclear Intent flags present |

**IMPORTANT:** If verdict is `NEEDS CLARIFICATION`, the audit MUST explicitly list every unclear intent flag and block implementation until resolved. AI should never guess design intent — ambiguity must be escalated to the designer.

## Post-Audit Actions

1. **If READY**: Proceed to `/teammate.align` or `/teammate.tasks`
2. **If CONDITIONAL**: Document workarounds in spec, proceed with caution
3. **If NOT READY**: Return findings to designer, block implementation
4. **If NEEDS CLARIFICATION**: Flag all unclear items, request designer clarification

## Cross-Reference

This skill integrates with:
- `contracts/ui/ui-spec.md` — UI component specifications per feature
- `figma-sync` skill — Figma resource synchronization (write to Figma)
- `/teammate.align` — Pre-implementation spec generation
- `/teammate.review` — Design-code alignment analysis (Pass E: UI Contract Consistency)
- `principles.md` — Design system token enforcement during implementation

## Quick Reference Checklist

| # | Check | Pass Criteria |
|---|-------|---------------|
| 1 | Variables | All values bound to semantic variables; no raw values |
| 2 | Auto Layout | 100% Auto Layout coverage; clear resize behaviors |
| 3 | Components | Variants for states; Properties for API; no Detached Instances |
| 4 | Naming | Semantic names; no defaults; consistent convention |
| 5 | Hygiene | Clean canvas; Dev annotations on interactions; ARIA hints |
