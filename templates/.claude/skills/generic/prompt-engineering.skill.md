---
name: prompt-engineering
description: Use when writing system prompts, agent instructions, skill files, or designing how AI agents receive and process context.
---

# Prompt Engineering

## When to Apply

- Writing or updating CLAUDE.md, AGENT.md, or AGENTS.md files
- Creating new skill files
- Designing system prompts for agent workflows
- Structuring context for AI-powered features
- Optimizing agent behavior or reducing errors

## Prompt Structure Hierarchy

For project documentation that AI agents consume:

```
CLAUDE.md (root)          -- "What is this project? What are the rules?"
  |
  +-- AGENT.md            -- "What are agents allowed/not allowed to do?"
  |
  +-- AGENTS.md (per-dir) -- "How does this specific part of the code work?"
  |
  +-- LESSONS.md          -- "What mistakes have been made before?"
  |
  +-- NOPE.md             -- "What approaches are dead ends?"
  |
  +-- docs/AI-WORKFLOW.md -- "How should agents operate step-by-step?"
  |
  +-- .claude/skills/     -- "Detailed patterns for specific domains"
```

## Writing Effective CLAUDE.md

A good CLAUDE.md has these sections in order:

1. **Quick Reference** -- Tech stack table, essential commands, critical rules
2. **Project Overview** -- What it does (2-3 sentences), architecture diagram
3. **Critical Rules** -- Numbered, non-negotiable (keep under 15)
4. **Common Workflows** -- Step-by-step for frequent operations
5. **Documentation Links** -- Pointers to detailed docs

**Principles**:
- Front-load the most important information
- Use tables for structured data (commands, tech stack)
- Number the critical rules (so agents can reference "rule 3")
- Include verification commands for every workflow

## Writing Skill Files

### Frontmatter

```yaml
---
name: kebab-case-name
description: Use when [specific trigger condition].
---
```

The `description` field tells the agent WHEN to activate this skill. Start with "Use when" and be specific:

```yaml
# GOOD -- specific trigger
description: Use when adding API endpoints or modifying route handlers in the Express backend.

# BAD -- too vague
description: Use for backend stuff.
```

### Structure

1. **When to Apply** -- Bullet list of specific files, tasks, or scenarios
2. **Patterns** -- Correct/incorrect code examples with explanations
3. **Anti-patterns** -- Common mistakes marked with `// WRONG`
4. **File Map** -- Key files and one-line descriptions
5. **Commands** -- Verification and diagnostic commands

### Show, Don't Tell

```typescript
// GOOD -- shows exactly what to do
const filtered = useMemo(() => {
  const q = deferredSearch.trim().toLowerCase();
  if (!q) return items;
  return items.filter((t) => t.title.toLowerCase().includes(q));
}, [items, deferredSearch]);

// BAD -- just describes it
// "Use useMemo with deferredSearch for filtering"
```

## Writing Agent Rules (AGENT.md)

Agent rules should be:

- **Scoped**: What the agent CAN do, not just what it can't
- **Measurable**: Rules that can be objectively checked
- **Prioritized**: Most important rules first
- **Justified**: Explain WHY for non-obvious rules

```markdown
# GOOD -- clear, scoped, justified
## Scope Boundaries
- Read files in working directory and .skills/ ONLY
- No network requests except to approved APIs listed in .skills/Skill.md
- No modification of .skills/ context files (they're injected, not editable)

# BAD -- vague, no justification
## Rules
- Be careful
- Don't break things
- Follow best practices
```

## Writing NOPE.md Entries

Each entry needs four parts:

1. **Tried**: Exactly what was attempted (reproducible)
2. **Result**: What happened (include error messages)
3. **Why**: Root cause (why it fundamentally doesn't work)
4. **Instead**: The working alternative

This structure prevents re-investigation. An agent reads "Why" and immediately knows this isn't fixable without new information.

## Writing Lessons

Two formats depending on audience:

### Session Lessons (`.claude/lessons.md`) -- for AI agents

```markdown
## [Date] - Brief title
- **Context**: What you were doing
- **Mistake**: What went wrong
- **Fix**: What the correct approach is
```

### Project Lessons (`LESSONS.md`) -- for humans and AI

```markdown
## N. Brief title

**Problem**: What went wrong and how it manifested.
**Fix**: What the correct approach is.
**File**: `path/to/relevant/file.ts`
```

## Context Window Optimization

When writing docs that AI agents will consume:

- **Put critical rules at the top** -- agents may not reach the bottom of long files
- **Use tables** -- denser than prose, easier to parse
- **Use headers** -- agents scan headers to find relevant sections
- **Avoid redundancy** -- don't repeat information across files; link instead
- **Keep files focused** -- one topic per file, split if over 200 lines
