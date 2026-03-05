---
name: testing-strategy
description: Use when writing tests, setting up test infrastructure, debugging test failures, or deciding what to test.
---

# Testing Strategy

## When to Apply

- Writing new tests for features or bug fixes
- Debugging failing tests
- Setting up test infrastructure (vitest, jest, cargo test, pytest)
- Deciding what needs tests and what doesn't

## What to Test

### Always Test
- Business logic and domain rules
- Data transformations (input -> output)
- Edge cases (empty, null, boundary values, overflow)
- Error handling paths
- API request/response contracts
- State transitions

### Usually Test
- Complex UI interactions (form validation, conditional rendering)
- Integration between modules
- Database queries (with test fixtures)
- Authentication/authorization flows

### Rarely Test (diminishing returns)
- Simple getters/setters with no logic
- Framework boilerplate (router config, module declarations)
- Third-party library behavior (they have their own tests)
- CSS/styling (use visual regression tools instead)

## Test Structure -- AAA Pattern

```typescript
test("filters templates by search query", () => {
  // Arrange -- set up the test data and state
  const templates = [
    { title: "RSS Feed", tags: ["media"] },
    { title: "Slack Bot", tags: ["social"] },
  ];

  // Act -- perform the action being tested
  const result = filterTemplates(templates, "rss");

  // Assert -- verify the outcome
  expect(result).toHaveLength(1);
  expect(result[0].title).toBe("RSS Feed");
});
```

## Naming Tests

Use descriptive names that explain the scenario and expected outcome:

```typescript
// GOOD -- reads like a specification
test("returns empty array when search query matches no templates")
test("handles special characters in search input without crashing")
test("filters are case-insensitive")

// BAD -- vague, doesn't describe behavior
test("search works")
test("test filter")
test("edge case")
```

## Testing React Components

```typescript
import { render, screen } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

test("search bar filters results on typing", async () => {
  const user = userEvent.setup();
  render(<TemplateGallery templates={mockTemplates} />);

  const input = screen.getByPlaceholderText(/search/i);
  await user.type(input, "rss");

  expect(screen.getByText("RSS Feed")).toBeInTheDocument();
  expect(screen.queryByText("Slack Bot")).not.toBeInTheDocument();
});
```

## Testing Async Code

```typescript
// With async/await
test("fetches templates from API", async () => {
  const templates = await listTemplates();
  expect(templates).toBeInstanceOf(Array);
  expect(templates.length).toBeGreaterThan(0);
});

// With mock timers
test("debounces search input", async () => {
  vi.useFakeTimers();
  // ... trigger search ...
  vi.advanceTimersByTime(300);
  // ... assert debounced call was made ...
  vi.useRealTimers();
});
```

## Test Fixtures and Factories

```typescript
// Factory function -- better than raw objects everywhere
function makeTemplate(overrides = {}) {
  return {
    title: "Default Template",
    slug: "default-template",
    category: "media",
    description: "A default template for testing",
    tags: ["test"],
    ...overrides,
  };
}

test("displays template title", () => {
  const template = makeTemplate({ title: "Custom Title" });
  // ...
});
```

## When Tests Fail

1. **Read the error message** -- it usually tells you exactly what's wrong
2. **Check if the test is correct** -- maybe the test needs updating, not the code
3. **Isolate** -- run the single failing test: `npm test -- --grep "test name"`
4. **Check recent changes** -- `git diff` to see what changed
5. **Don't just delete the test** -- if it was passing before, something broke

## Commands

```bash
# JavaScript/TypeScript (vitest)
npx vitest run                    # Run all tests once
npx vitest                        # Watch mode
npx vitest run --reporter verbose # Detailed output
npx vitest run src/utils          # Run tests in a directory

# Rust
cargo test                        # All tests
cargo test test_name              # Single test
cargo test -- --nocapture         # Show println! output
cargo test module_name            # Tests in a module

# Python
pytest                            # All tests
pytest -v                         # Verbose
pytest -k "test_name"             # Single test
pytest --tb=short                 # Short tracebacks
```
