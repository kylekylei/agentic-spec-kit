---
name: a11y-compliance
description: Comprehensive Accessibility Expert for WCAG 2.2 AA/AAA compliance, ARIA patterns, mobile accessibility, Taiwan MODA, and automated testing with axe-core. Use when (1) building accessible UI components, (2) auditing code for accessibility issues, (3) implementing ARIA patterns (tabs, modals, menus), (4) writing axe-core tests (Jest, Playwright, Cypress), (5) ensuring Taiwan MODA compliance, or (6) writing accessible React/Vue/Svelte/React Native code. Dynamically loaded — only active when project has frontend/UI.
---

# Accessibility Compliance Expert

Act as a Senior Frontend Engineer & Accessibility Expert. Philosophy: "Inclusive design is better design for everyone."

## Dynamic Detection

This skill is loaded **conditionally** based on project characteristics.

### Detection Signals

**Primary (context.md tech stack):**
- Keywords: frontend, UI, React, Vue, Svelte, Next.js, Nuxt, SvelteKit, HTML, CSS, Tailwind, web, mobile, app

**Secondary (codebase auto-detect):**
- File extensions: `*.tsx`, `*.jsx`, `*.vue`, `*.svelte`, `*.html`, `*.css`, `*.scss`
- Directories: `src/components/`, `src/pages/`, `src/routes/`, `src/views/`, `app/`
- Dependencies in package.json: `react`, `vue`, `svelte`, `@angular/core`, `tailwindcss`
- Config files: `tailwind.config.*`, `vite.config.*`, `next.config.*`

**Result:**
- context.md has frontend markers → load silently
- context.md missing but codebase detected → load + suggest: "偵測到前端 UI 代碼，已自動載入 a11y-compliance skill。建議更新 context.md 標記。"
- Neither detected → do not load

### Lifecycle Integration

| Stage | Role | What to do |
|-------|------|------------|
| `/teammate.plan` | Remind | Flag a11y requirements for UI components in Architecture section |
| `/teammate.execute` | Guide | Load as Recommended context for `[UI]` and `[LOGIC+UI]` actions |
| `/teammate.review` | Check | Verify a11y coverage in Pass D2 |
| `/teammate.audit` | Judge | Sarcasmotron performs adversarial POUR scan against all rules |

## Quick Decision Guide

| Task | Action |
|------|--------|
| Building new component | Use native HTML first, add ARIA only if needed |
| Icon-only button | Add `aria-label` or visually-hidden text |
| Modal/Dialog | Trap focus, return focus on close, `aria-modal="true"` |
| SPA route change | Move focus to `<main>` or new `<h1>` |
| Form validation | Use `aria-invalid` + `aria-describedby` |
| Hide decorative element | Use `aria-hidden="true"` |
| Hide from visual only | Use `.visually-hidden` class |
| Dynamic content update | Use `aria-live="polite"` or `role="status"` |
| Touch target | Minimum 24×24px (AA), 44×44px recommended |
| Write a11y test | Use axe-core with Jest/Playwright/Cypress |

## POUR Principles

### Perceivable (可感知)

**Text Alternatives**
- All `<img>` must have `alt` (empty for decorative)
- Complex charts: use `aria-describedby` for long description
- Icon buttons: require `aria-label`

**Structure**
```html
<!-- Landmarks -->
<header role="banner">
<nav aria-label="Main">
<main> <!-- Only ONE per page -->
<aside>
<footer role="contentinfo">

<!-- Headings: No skipping levels -->
<h1>Page Title</h1>
  <h2>Section</h2>
    <h3>Subsection</h3>
```

**Color Contrast**
- Normal text: **4.5:1** minimum (AA), 7:1 (AAA)
- Large text (≥18pt or ≥14pt bold): **3:1** minimum
- UI components: **3:1** minimum

### Operable (可操作)

**Keyboard**
- Everything mouse-clickable must be keyboard-accessible
- Never use `tabindex > 0`
- Visible focus indicators required (no `outline: none`)

**Touch Targets (WCAG 2.2)**
- Level AA: **24×24 CSS pixels** minimum
- Level AAA: **44×44 CSS pixels** minimum

**Focus Management**
```javascript
// Modal: trap focus and return on close
const openModal = () => {
  previousFocus = document.activeElement;
  modalRef.current?.focus();
  trapFocus(modalRef);
};
const closeModal = () => {
  previousFocus?.focus();
};

// SPA Route Change
useEffect(() => {
  mainRef.current?.focus();
}, [route]);
```

### Understandable (可理解)

**Language**
```html
<html lang="zh-Hant-TW">
<span lang="en">Hello</span>
```

**Error Handling**
```html
<input id="email" aria-invalid="true" aria-describedby="email-error">
<span id="email-error" role="alert">請輸入有效的電子郵件地址</span>
```

**Links vs Buttons**
- `<a>`: Navigate (URL change)
- `<button>`: Action (submit, toggle, delete)
- Never: `<a href="#">` or `<div onclick>`

### Robust (穩健性)

**ARIA First Principle**: Best ARIA is no ARIA. Use native HTML first.

## Key ARIA Patterns

### Accessible Button
```tsx
<button
  aria-busy={isLoading}
  aria-disabled={disabled || isLoading}
  className="min-h-[44px] min-w-[44px] focus-visible:ring-2"
>
  {isLoading ? <><span className="sr-only">Loading</span><Spinner aria-hidden /></> : children}
</button>
```

### Tabs
```tsx
<div role="tablist" aria-label="Content tabs">
  <button role="tab" aria-selected="true" aria-controls="panel-1" tabIndex={0}>Tab 1</button>
  <button role="tab" aria-selected="false" aria-controls="panel-2" tabIndex={-1}>Tab 2</button>
</div>
<div role="tabpanel" id="panel-1" aria-labelledby="tab-1" tabIndex={0}>Content</div>
```

### Live Regions
```tsx
// Status (polite)
<div role="status" aria-live="polite">{count} results found</div>

// Error (assertive)
<div role="alert" aria-live="assertive">Error: {message}</div>
```

## CSS Utilities

```css
.visually-hidden {
  position: absolute;
  width: 1px; height: 1px;
  padding: 0; margin: -1px;
  overflow: hidden;
  clip: rect(0, 0, 0, 0);
  white-space: nowrap; border: 0;
}

:focus-visible {
  outline: 2px solid var(--focus-color);
  outline-offset: 2px;
}

@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Automated Testing with axe-core

```javascript
// Jest / Vitest
import { axe, toHaveNoViolations } from 'jest-axe';
expect.extend(toHaveNoViolations);

it('should be accessible', async () => {
  const { container } = render(<MyComponent />);
  expect(await axe(container)).toHaveNoViolations();
});

// Playwright
import AxeBuilder from '@axe-core/playwright';
const results = await new AxeBuilder({ page })
  .withTags(['wcag2a', 'wcag2aa'])
  .analyze();
expect(results.violations).toEqual([]);
```

See [Testing with axe-core](references/testing-with-axe.md) for full API reference.

## Audit Workflow

When auditing code:
1. Scan using POUR principles
2. Reference [WCAG Checklist](references/wcag-checklist.md)
3. Run `axe.run()` for automated detection
4. Generate repair plan in **Traditional Chinese**:
   - Format: `[ ] **修復**: <描述> in <file path>`
   - Explain *why* based on WCAG
5. Wait for user approval before modifying

## References

- [WCAG Guidelines](references/wcag-guidelines.md) - Complete WCAG 2.2 guidelines with code examples
- [WCAG Checklist](references/wcag-checklist.md) - Checklist with Taiwan MODA requirements
- [ARIA Patterns](references/aria-patterns.md) - Accordion, Tabs, Menu, Combobox, Dialog patterns
- [Framework Guides](references/framework-guides.md) - React, Vue, Svelte specific patterns
- [Mobile Accessibility](references/mobile-accessibility.md) - iOS VoiceOver, Android TalkBack, React Native
- [Testing with axe-core](references/testing-with-axe.md) - API reference, Jest/Playwright/Cypress integration
