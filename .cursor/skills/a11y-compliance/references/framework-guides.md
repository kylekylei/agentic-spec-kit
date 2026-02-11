# Framework-Specific Accessibility Guides

## React

### Avoid "Div Soup" with Fragments

```jsx
// Bad: Breaks semantic structure
function ListItems() {
  return (
    <div>  {/* This breaks <ul> > <li> requirement */}
      <li>Item 1</li>
      <li>Item 2</li>
    </div>
  );
}

// Good: Use Fragment
function ListItems() {
  return (
    <>
      <li>Item 1</li>
      <li>Item 2</li>
    </>
  );
}
```

### Focus Management with Refs

```jsx
function Modal({ isOpen, onClose, triggerRef }) {
  const modalRef = useRef(null);

  useEffect(() => {
    if (isOpen) {
      modalRef.current?.focus();
    }
  }, [isOpen]);

  const handleClose = () => {
    onClose();
    triggerRef.current?.focus(); // Return focus
  };

  return (
    <div ref={modalRef} tabIndex={-1} role="dialog" aria-modal="true">
      {/* Modal content */}
      <button onClick={handleClose}>Close</button>
    </div>
  );
}
```

### Route Change Focus (React Router)

```jsx
function App() {
  const location = useLocation();
  const mainRef = useRef(null);

  useEffect(() => {
    mainRef.current?.focus();
  }, [location.pathname]);

  return (
    <main ref={mainRef} tabIndex={-1}>
      <Routes>...</Routes>
    </main>
  );
}
```

### React Checklist

- [ ] No extra divs breaking semantic structure
- [ ] Modal focus trapped and returned on close
- [ ] Route changes move focus to content
- [ ] Interactive elements use `useRef` for programmatic focus

---

## Vue

### v-if vs v-show vs visually-hidden

| Directive | DOM | Screen Reader | Use Case |
|-----------|-----|---------------|----------|
| `v-if` | Removed | Hidden | Conditional content |
| `v-show` | Present | Hidden | Visual toggle |
| `.visually-hidden` | Present | Visible | SR-only content |

```vue
<!-- v-if: Completely removed -->
<div v-if="isVisible">Content</div>

<!-- v-show: display: none (hidden from SR too) -->
<div v-show="isVisible">Content</div>

<!-- visually-hidden: Hidden visually, available to SR -->
<span class="visually-hidden">Additional context</span>
```

### Scoped Slots for Semantic Flexibility

```vue
<!-- Parent controls semantic markup -->
<GenericList :items="items">
  <template #item="{ item }">
    <li>{{ item.name }}</li>  <!-- Parent provides <li> -->
  </template>
</GenericList>

<!-- GenericList.vue -->
<ul>
  <slot v-for="item in items" name="item" :item="item" />
</ul>
```

### Vue Checklist

- [ ] Using `.visually-hidden` for screen-reader-only text
- [ ] `v-if` removal doesn't create focus vacuum
- [ ] Scoped slots allow semantic tag injection
- [ ] Native elements over custom ARIA

---

## Svelte

### Leverage Svelte Actions

```svelte
<!-- Focus trap action -->
<script>
  function focusTrap(node) {
    const focusable = node.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
    const first = focusable[0];
    const last = focusable[focusable.length - 1];

    function handleKeydown(e) {
      if (e.key === 'Tab') {
        if (e.shiftKey && document.activeElement === first) {
          e.preventDefault();
          last.focus();
        } else if (!e.shiftKey && document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    }

    node.addEventListener('keydown', handleKeydown);
    first?.focus();

    return {
      destroy() {
        node.removeEventListener('keydown', handleKeydown);
      }
    };
  }
</script>

<div use:focusTrap role="dialog" aria-modal="true">
  <!-- Dialog content -->
</div>
```

### Dynamic ARIA Attributes

```svelte
<script>
  let isExpanded = false;
  let isCurrent = true;
</script>

<!-- Correct: undefined removes attribute -->
<button
  aria-expanded={isExpanded}
  aria-current={isCurrent ? 'page' : undefined}
>
  Toggle
</button>
```

### Respond to Compiler Warnings

Svelte identifies A11y issues at compile time:
- `a11y-missing-attribute`: Missing `alt` on images
- `a11y-click-events-have-key-events`: Click handlers need keyboard equivalent
- `a11y-no-noninteractive-element-interactions`: Interactive events on non-interactive elements

**Never suppress these warnings.** Fix at source.

### Svelte Checklist

- [ ] Using actions for complex interactive logic
- [ ] All toggleable components have `aria-` attributes
- [ ] No `a11y-` warnings in build log
- [ ] Boolean ARIA attributes handled correctly (undefined to remove)

---

## Common Patterns (All Frameworks)

### Skip Link

```html
<a href="#main-content" class="skip-link">
  Skip to main content
</a>

<main id="main-content" tabindex="-1">
  <!-- Page content -->
</main>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  padding: 8px;
  z-index: 100;
}
.skip-link:focus {
  top: 0;
}
</style>
```

### Announce Dynamic Content

```html
<!-- Status messages -->
<div role="status" aria-live="polite">
  {{ statusMessage }}
</div>

<!-- Urgent alerts -->
<div role="alert" aria-live="assertive">
  {{ errorMessage }}
</div>
```

### Form Error Pattern

```html
<label for="email">Email</label>
<input
  id="email"
  type="email"
  aria-invalid="true"
  aria-describedby="email-error"
>
<span id="email-error" role="alert">
  Please enter a valid email address
</span>
```
