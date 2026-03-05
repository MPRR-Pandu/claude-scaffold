---
name: agentic-patterns
description: Use when orchestrating multi-step autonomous tasks, managing agent context, handling tool use, or designing agent-to-agent workflows.
---

# Agentic Patterns

## When to Apply

- Executing multi-step tasks autonomously
- Deciding when to use subagents vs doing work directly
- Managing context windows and token budgets
- Designing agent pipelines or multi-agent systems
- Recovering from failures mid-task

## The Agent Loop

Every autonomous task follows this loop:

```
OBSERVE  ->  PLAN  ->  ACT  ->  VERIFY  ->  REFLECT
   |                                            |
   +--------------------------------------------+
                  (repeat until done)
```

1. **Observe**: Read the task, gather context, understand the current state
2. **Plan**: Decide what to do, in what order, with what tools
3. **Act**: Execute one step at a time
4. **Verify**: Check the result -- did it work? Any side effects?
5. **Reflect**: Should the plan change? Did I learn something? Record it.

## When to Use Subagents

| Situation | Approach |
|-----------|----------|
| Need to search 10+ files | Subagent (explore) |
| Single file edit | Do it directly |
| Independent research tasks | Multiple subagents in parallel |
| Sequential dependent steps | Do it yourself, sequentially |
| Complex question about codebase | Subagent (explore, thorough) |
| Simple grep/find | Do it directly with tools |

**Rule**: If you're about to make 5+ tool calls just to gather context, use a subagent instead.

## Context Management

### Token Budget Awareness

- Read large files with offset/limit, not all at once
- Use grep to find specific content instead of reading entire files
- Summarize findings from subagents -- don't echo raw output
- Drop irrelevant context as the task progresses

### Information Hierarchy

```
1. CLAUDE.md          -- Global project rules (read once per session)
2. AGENTS.md          -- Directory-specific rules (read when entering a directory)
3. LESSONS.md         -- Known pitfalls (scan before starting)
4. NOPE.md            -- Dead ends (check before trying novel approaches)
5. .claude/skills/    -- Domain patterns (loaded on demand)
6. Source code         -- Read as needed (just-in-time, not upfront)
```

## Error Recovery

When a step fails:

1. **Read the error** -- the message tells you what went wrong
2. **Don't retry blindly** -- understand WHY it failed first
3. **Check NOPE.md** -- is this a known dead end?
4. **Try a different approach** -- not the same thing again
5. **Escalate if stuck** -- ask the human after 2 failed attempts, not 10

### Retry Strategy

```
Attempt 1: Try the straightforward approach
Attempt 2: Try with more context / different parameters  
Attempt 3: Try a fundamentally different approach
Attempt 4: STOP. Report what you tried and what failed. Ask for help.
```

## Parallel vs Sequential

```
PARALLEL (independent):            SEQUENTIAL (dependent):
  +---> Task A ---+                  Task A
  |               |                    |
  +---> Task B ---+---> Combine       Task B (needs A's output)
  |               |                    |
  +---> Task C ---+                  Task C (needs B's output)
```

- If tasks don't depend on each other's output, run them in parallel
- If task B needs task A's result, run sequentially
- When in doubt, sequential is safer (parallel can waste tokens on stale context)

## Tool Use Discipline

### Batch Independent Calls

```
// GOOD -- parallel tool calls in one message
[Read file A] [Read file B] [Read file C]

// BAD -- sequential when they're independent
[Read file A] -> wait -> [Read file B] -> wait -> [Read file C]
```

### Prefer Specialized Tools

```
// GOOD
[Grep tool] to find occurrences
[Edit tool] to make changes
[Glob tool] to find files

// BAD
[Bash: grep ...] when Grep tool exists
[Bash: sed ...] when Edit tool exists
[Bash: find ...] when Glob tool exists
```

## Self-Improvement Protocol

After completing a task, ask yourself:

1. Did I make any mistakes? -> Record in `.claude/lessons.md`
2. Did I discover a dead end? -> Record in `NOPE.md`
3. Did I find a reusable pattern? -> Consider adding to a skill file
4. Did I waste time on something preventable? -> Update workflow docs

## Scope Boundaries

Agents must respect explicit scope boundaries:

- **Working directory**: Stay within unless explicitly told otherwise
- **Read-only files**: Don't modify AGENT.md, CLAUDE.md, or .skills/ context
- **Credentials**: Never read, log, or expose secrets
- **External systems**: Only interact with approved APIs/services
- **Destructive operations**: Never force-push, drop databases, or delete production resources without explicit approval
