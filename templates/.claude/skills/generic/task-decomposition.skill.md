---
name: task-decomposition
description: Use when breaking down complex tasks into subtasks, planning multi-step implementations, or deciding the order of operations for a feature or fix.
---

# Task Decomposition

## When to Apply

- Receiving a complex request (3+ files, new feature, refactoring)
- Planning before implementation
- Breaking a large PR into smaller, reviewable pieces
- Estimating effort or identifying risks

## The Decomposition Process

```
1. UNDERSTAND  -- What is the end state? What changes?
2. INVENTORY   -- What files, components, APIs are involved?
3. SEQUENCE    -- What order? What depends on what?
4. ESTIMATE    -- How big is each piece? Where are the risks?
5. TRACK       -- Create task list, update as you go
```

## Sizing Guide

| Size | Characteristics | Approach |
|------|----------------|----------|
| **Trivial** | 1 file, < 10 lines | Just do it, no task list needed |
| **Small** | 1-3 files, clear scope | Brief mental plan, then execute |
| **Medium** | 3-7 files, known patterns | Create task list, execute sequentially |
| **Large** | 7+ files, new patterns | Full plan, break into sub-PRs if possible |
| **Epic** | Cross-cutting, architectural | Design doc first, phased implementation |

## Decomposition Patterns

### Feature Addition (Vertical Slice)

```
1. Data layer (types, models, schema)
2. Backend (API endpoint, business logic)
3. Frontend (component, state management)
4. Wiring (connect frontend to backend)
5. Tests
6. Verify (build, lint, test)
```

### Bug Fix

```
1. Reproduce the bug
2. Write a failing test
3. Find the root cause
4. Fix the code
5. Verify test passes
6. Check for sibling bugs
7. Update LESSONS.md if non-obvious
```

### Refactoring

```
1. Identify what's changing and what's staying
2. Write characterization tests (if none exist)
3. Make the structural change
4. Update all references
5. Verify no behavior changed
6. Clean up (remove old code, update docs)
```

### Security Fix / Dependency Bump

```
1. Audit current state (npm audit / cargo audit)
2. Fix auto-fixable vulnerabilities
3. Bump packages (minor-safe for build tools)
4. Verify TypeScript / build passes
5. Re-audit to confirm
6. Document remaining unfixable issues
```

## Dependency Ordering

Always identify dependencies before starting:

```
Task A: Create the data type     (no deps)
Task B: Create the API endpoint  (depends on A)
Task C: Create the UI component  (depends on A)
Task D: Wire UI to API           (depends on B and C)
Task E: Write tests              (depends on D)

Execution order:
  A -> [B, C] in parallel -> D -> E
```

## Task List Management

### Creating Tasks

- **Be specific**: "Add SearchBar component to TemplateGallery.tsx" not "Add search"
- **Include verification**: Each task should end with "Verify: ..."
- **Order matters**: Put tasks in execution order
- **One in-progress**: Don't start task N+1 until task N is done

### During Execution

- Mark tasks `in_progress` when you start them
- Mark `completed` immediately when done (don't batch)
- Add new tasks as you discover them
- Mark `cancelled` with reason if no longer needed

### When Plans Change

Plans will change. That's normal. When they do:

1. Stop the current task
2. Re-assess: What changed? What's the new plan?
3. Update the task list
4. Continue from the updated plan

## Risk Identification

Before starting, flag potential risks:

| Risk | Indicator | Mitigation |
|------|-----------|------------|
| **Breaking change** | Modifying a shared interface | Check all consumers first |
| **Performance** | Loop over large dataset | Measure before and after |
| **Security** | User input handling | Validate, sanitize, escape |
| **Compatibility** | Major version bump | Test in isolation first |
| **Data loss** | Modifying persistence layer | Backup and migration plan |

## Anti-Patterns

### Premature Optimization

Don't optimize before you have working code. Sequence:
1. Make it work
2. Make it right (clean, tested)
3. Make it fast (only if measured as slow)

### Yak Shaving

If you find yourself 4 levels deep in prerequisite tasks, stop and reassess:
- Is the original task still the right approach?
- Can you work around the prerequisites?
- Should you ask for help?

### Analysis Paralysis

If you've been planning for more than 10 minutes without writing code:
- Start with the smallest, most certain piece
- The plan will improve once you see real code
- Iterate on the plan as you learn
