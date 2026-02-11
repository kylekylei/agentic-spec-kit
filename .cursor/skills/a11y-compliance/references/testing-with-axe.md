# Testing with axe-core

axe-core is the accessibility testing engine that can find ~57% of WCAG issues automatically with zero false positives.

## Quick Start

```bash
npm install axe-core --save-dev
```

```javascript
// Basic test
axe.run().then(results => {
  console.log('Violations:', results.violations);
  console.log('Passes:', results.passes);
});
```

## Core API

### axe.run(context, options)

```javascript
// Test entire page
axe.run().then(results => { /* ... */ });

// Test specific element
axe.run('#main-content').then(results => { /* ... */ });

// With options
axe.run(document, {
  runOnly: ['wcag2a', 'wcag2aa'],
  rules: { 'color-contrast': { enabled: true } }
}).then(results => { /* ... */ });
```

### Context Parameter

| Type | Example |
|------|---------|
| Element | `document.getElementById('main')` |
| Selector | `'#content'`, `'.main'` |
| Include/Exclude | `{ include: ['#main'], exclude: ['.ad'] }` |
| Frames | `{ fromFrames: ['iframe#pay', 'form'] }` |

### Options Parameter

| Property | Default | Description |
|----------|---------|-------------|
| `runOnly` | all | Limit rules by tags or IDs |
| `rules` | n/a | Enable/disable specific rules |
| `resultTypes` | all | Limit result types for performance |

### runOnly Examples

```javascript
// By WCAG level tags
axe.run({ runOnly: ['wcag2a', 'wcag2aa'] });

// By specific rules
axe.run({ runOnly: ['color-contrast', 'image-alt', 'label'] });

// Combined
axe.run({
  runOnly: ['wcag2a'],
  rules: {
    'color-contrast': { enabled: true },  // Add AA rule
    'valid-lang': { enabled: false }       // Exclude
  }
});
```

### axe.configure(options)

```javascript
axe.configure({
  rules: [{ id: 'color-contrast', enabled: false }],
  locale: { lang: 'zh-TW', /* ... */ }
});
```

## Results Object

```javascript
{
  violations: [],   // Failed - must fix
  passes: [],       // Passed tests
  incomplete: [],   // Needs manual review
  inapplicable: [], // Rules that didn't apply
  url: '...',
  timestamp: '...'
}
```

### Result Entry

```javascript
{
  id: 'color-contrast',
  impact: 'serious',  // minor | moderate | serious | critical
  help: 'Elements must have sufficient color contrast',
  helpUrl: 'https://dequeuniversity.com/rules/axe/...',
  nodes: [{
    html: '<p style="color: #ccc">...</p>',
    target: ['#main > p:nth-child(2)'],
    failureSummary: '...'
  }]
}
```

## WCAG Tags

| Tag | Standard |
|-----|----------|
| `wcag2a` | WCAG 2.0 Level A |
| `wcag2aa` | WCAG 2.0 Level AA |
| `wcag21a` | WCAG 2.1 Level A |
| `wcag21aa` | WCAG 2.1 Level AA |
| `wcag22aa` | WCAG 2.2 Level AA |
| `best-practice` | Industry best practices |

## Framework Integration

### Jest / Vitest

```javascript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

it('should have no accessibility violations', async () => {
  const { container } = render(<MyComponent />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```

### Playwright

```javascript
import { test, expect } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';

test('should pass accessibility checks', async ({ page }) => {
  await page.goto('/');
  const results = await new AxeBuilder({ page })
    .withTags(['wcag2a', 'wcag2aa'])
    .analyze();
  expect(results.violations).toEqual([]);
});
```

### Cypress

```javascript
import 'cypress-axe';

describe('Accessibility', () => {
  it('has no detectable a11y violations', () => {
    cy.visit('/');
    cy.injectAxe();
    cy.checkA11y();
  });
});
```

### Svelte (with Testing Library)

```javascript
import { render } from '@testing-library/svelte';
import { axe } from 'jest-axe';
import MyComponent from './MyComponent.svelte';

it('should be accessible', async () => {
  const { container } = render(MyComponent);
  expect(await axe(container)).toHaveNoViolations();
});
```

## Performance Tips

### Large Pages

```javascript
// Only get violations (skip passes for speed)
axe.run({ resultTypes: ['violations'] });

// Exclude heavy areas
axe.run({ exclude: ['.comments', '.sidebar'] });
```

### CI/CD Integration

```javascript
// Exit with error code if violations found
const results = await axe.run();
if (results.violations.length > 0) {
  console.error(JSON.stringify(results.violations, null, 2));
  process.exit(1);
}
```

## Common Rule IDs

| Rule | Description |
|------|-------------|
| `image-alt` | Images must have alt text |
| `button-name` | Buttons must have discernible text |
| `color-contrast` | Text must have sufficient contrast |
| `label` | Form elements must have labels |
| `link-name` | Links must have discernible text |
| `html-has-lang` | `<html>` must have lang attribute |
| `landmark-one-main` | Page must have one main landmark |
| `region` | Content must be in landmarks |
