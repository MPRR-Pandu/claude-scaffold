---
name: frontend-patterns
description: Use when adding UI features, search/filter components, modals, or working with React hooks (useMemo, useEffect, useDeferredValue) in any frontend project.
---

# Frontend Patterns

## When to Apply

- Adding new UI features (search bars, filters, modals, forms)
- Working with `useMemo`, `useEffect`, `useDeferredValue`, or `useCallback`
- Building components with user input and real-time filtering
- Adding CSS styles or theming

## Trace the User Flow Before Writing Code

Before adding a UI feature, trace the exact user journey:

1. What button/action triggers the feature?
2. What component renders at that point?
3. Add the feature to **that** component, not the nearest visible one.

## useDeferredValue for Input-Driven Filtering

When filtering a list on every keystroke, use `useDeferredValue` to keep the input responsive:

```tsx
const [searchQuery, setSearchQuery] = useState("");
const deferredSearch = useDeferredValue(searchQuery);

// Input reads searchQuery (immediate -- no typing lag)
<input value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} />

// Filtering reads deferredSearch (deferred -- React batches the expensive work)
const filtered = useMemo(() => {
  const q = deferredSearch.trim().toLowerCase();
  if (!q) return items;
  return items.filter((item) => item.title.toLowerCase().includes(q));
}, [items, deferredSearch]);
```

**Critical**: All UI that depends on the filtered results must read from `deferredSearch`, not `searchQuery`. This includes empty-state messages, result counts, and highlighted matches. Mixing immediate and deferred values causes visual mismatches during fast typing.

```tsx
// WRONG -- mismatch between immediate and deferred
{filtered.length === 0 && searchQuery && `No results for "${searchQuery}"`}

// CORRECT -- both use deferred
{filtered.length === 0 && deferredSearch && `No results for "${deferredSearch}"`}
```

## Consolidate Related useEffects

Merge effects that share the same lifecycle scope:

```tsx
// WRONG -- orphaned timer, split cleanup
useEffect(() => {
  setTimeout(() => inputRef.current?.focus(), 100);  // no cleanup!
}, []);
useEffect(() => {
  const handler = (e: KeyboardEvent) => { /* ... */ };
  window.addEventListener("keydown", handler);
  return () => window.removeEventListener("keydown", handler);
}, [deps]);

// CORRECT -- single effect, complete cleanup
useEffect(() => {
  const focusTimer = setTimeout(() => inputRef.current?.focus(), 100);
  const handler = (e: KeyboardEvent) => { /* ... */ };
  window.addEventListener("keydown", handler);
  return () => {
    clearTimeout(focusTimer);
    window.removeEventListener("keydown", handler);
  };
}, [deps]);
```

## useMemo -- Clear Multi-Step Filtering

When filtering has multiple stages, structure with clear steps and early returns:

```tsx
const filtered = useMemo(() => {
  // Step 1: filter by category
  const byCategory = category === "all"
    ? items
    : items.filter((t) => t.category === category);

  // Step 2: filter by search
  const q = deferredSearch.trim().toLowerCase();
  if (!q) return byCategory;

  return byCategory.filter((t) =>
    t.title.toLowerCase().includes(q) ||
    t.description.toLowerCase().includes(q)
  );
}, [items, category, deferredSearch]);
```

## Escape Key UX for Modals with Search

Escape clears search first, then closes modal:

```tsx
if (e.key === "Escape") {
  if (searchQuery && document.activeElement === searchRef.current) {
    setSearchQuery("");    // First Escape: clear search
  } else {
    onClose();             // Second Escape: close modal
  }
}
```

## Search Bar Checklist

When adding a search bar to any component:

1. State: `useState` for query + `useDeferredValue` for filtering
2. Ref: `useRef<HTMLInputElement>` for auto-focus and Escape handling
3. Auto-focus on mount with `clearTimeout` cleanup
4. Clear button that resets query and re-focuses input
5. Keyboard: Escape clears, then closes parent
6. Empty state uses deferred value, not immediate
7. Focus ring with accent color for visual feedback
