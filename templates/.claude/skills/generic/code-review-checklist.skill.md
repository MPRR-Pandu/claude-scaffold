---
name: code-review-checklist
description: Use when reviewing code, preparing a PR for review, or self-checking work before committing.
---

# Code Review Checklist

## When to Apply

- Before creating a commit or PR
- When reviewing someone else's code
- After completing a feature or bug fix
- When doing self-review before marking work as done

## Pre-Commit Checklist

### Correctness
- [ ] Does the code do what it's supposed to do?
- [ ] Are edge cases handled (empty arrays, null values, zero, negative numbers)?
- [ ] Are error cases handled gracefully (try/catch, Result types, error boundaries)?
- [ ] No off-by-one errors in loops, slices, or pagination?

### Security
- [ ] No hardcoded secrets (API keys, tokens, passwords)
- [ ] User input is validated/sanitized before use
- [ ] No SQL injection, XSS, or shell injection vectors
- [ ] Sensitive data is not logged or exposed in error messages

### Performance
- [ ] No unnecessary re-renders (React: missing memo, deps array issues)
- [ ] No N+1 queries or unbounded loops over large datasets
- [ ] Expensive computations use memoization where appropriate
- [ ] No memory leaks (event listeners cleaned up, subscriptions unsubscribed)

### Consistency
- [ ] Follows existing code style and naming conventions
- [ ] New files are in the right directory
- [ ] Imports are organized (framework, third-party, local)
- [ ] No commented-out code left behind (delete it, git has history)

### Testing
- [ ] New logic has tests (or existing tests are updated)
- [ ] Tests actually assert the right behavior (not just "doesn't crash")
- [ ] Edge cases are tested
- [ ] Build passes: `npm run build` / `cargo check`
- [ ] Tests pass: `npm test` / `cargo test`

### Documentation
- [ ] Complex logic has comments explaining WHY (not what)
- [ ] Public APIs have doc comments / JSDoc
- [ ] README or CLAUDE.md updated if architecture changed
- [ ] LESSONS.md updated if a non-obvious fix was discovered

## Common Anti-Patterns to Catch

### React / TypeScript
- `useEffect` that should be `useMemo` (derived state)
- Missing cleanup in `useEffect` (timers, listeners, subscriptions)
- Mixing immediate and deferred values (`searchQuery` vs `deferredSearch`)
- `any` type used where a proper type exists
- Inline styles where CSS variables or classes should be used

### General
- Magic numbers without named constants
- Functions doing too many things (should be split)
- Deep nesting (> 3 levels of if/for -- refactor to early returns)
- Catch blocks that swallow errors silently
- Copy-pasted code that should be a shared function

### Git
- Unrelated changes bundled in one commit
- Commit message doesn't describe the WHY
- Files committed that should be in .gitignore (node_modules, build artifacts, .env)
- Large binary files committed (use Git LFS or external storage)

## Severity Levels

| Level | Action | Example |
|-------|--------|---------|
| **Blocker** | Must fix before merge | Security vulnerability, data loss, crash |
| **Major** | Should fix before merge | Bug, missing error handling, wrong behavior |
| **Minor** | Fix if easy, otherwise create follow-up | Naming, style, minor optimization |
| **Nit** | Optional, author's preference | Formatting, import order, comment wording |
