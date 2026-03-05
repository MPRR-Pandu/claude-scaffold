# Project-Specific Skills

This directory is for skills that are specific to **this** project's codebase, domain, and patterns.

## How to Add a Skill

1. Copy `_template.skill.md` to a new file:
   ```bash
   cp _template.skill.md my-domain.skill.md
   ```

2. Fill in the YAML frontmatter:
   - `name`: kebab-case identifier (e.g., `api-patterns`, `data-model`, `auth-flow`)
   - `description`: Start with "Use when..." to tell Claude when to activate this skill

3. Fill in the sections:
   - **When to Apply**: Specific file paths, components, or tasks that trigger this skill
   - **Patterns**: Code examples showing correct and incorrect approaches
   - **File Map**: Key files and what they contain

4. Force-add to git (since `.claude/` may be gitignored):
   ```bash
   git add -f .claude/skills/project/my-domain.skill.md
   ```

## Examples of Project-Specific Skills

- `api-patterns.skill.md` -- How your API endpoints are structured, auth middleware, error handling
- `data-model.skill.md` -- Database schema, ORM patterns, migration conventions
- `auth-flow.skill.md` -- Authentication/authorization architecture, session management
- `deployment.skill.md` -- CI/CD pipeline, environment config, release process
- `component-library.skill.md` -- Design system, component API conventions, theming

## Naming Convention

- Use kebab-case: `my-skill-name.skill.md`
- Files starting with `_` are templates/docs and won't be loaded as skills
