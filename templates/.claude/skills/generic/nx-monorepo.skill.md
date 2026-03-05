---
name: nx-monorepo
description: Use when working in an Nx monorepo -- running builds, tests, lints, understanding project dependencies, managing workspace configuration, or adding new projects.
---

# Nx Monorepo Management

## When to Apply

- Running builds, tests, or lints across a monorepo
- Understanding project dependencies and task orchestration
- Adding new projects or libraries to the workspace
- Debugging Nx cache, dependency graph, or task pipeline issues
- Configuring `nx.json`, `project.json`, or workspace plugins

## Essential Commands

| Task | Command |
|------|---------|
| Run a target for one project | `npx nx <target> <project>` |
| Run a target for all projects | `npx nx run-many -t <target>` |
| Run affected projects only | `npx nx affected -t <target>` |
| Dependency graph (visual) | `npx nx graph` |
| Show what Nx will run | `npx nx show projects` |
| List project targets | `npx nx show project <name>` |
| Reset Nx cache | `npx nx reset` |
| Migrate Nx version | `npx nx migrate latest` |

## Project Configuration

### `nx.json` (workspace-level)

```json
{
  "targetDefaults": {
    "build": {
      "dependsOn": ["^build"],       // Build deps first
      "cache": true                   // Cache build output
    },
    "test": {
      "cache": true
    }
  },
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "production": ["default", "!{projectRoot}/**/*.spec.*"]
  }
}
```

### `project.json` (project-level)

```json
{
  "name": "my-app",
  "targets": {
    "build": { "command": "vite build" },
    "dev":   { "command": "vite", "continuous": true },
    "test":  { "command": "vitest run" },
    "lint":  { "command": "eslint src/" }
  }
}
```

For non-JS projects (Rust, Go, Python), use `command` targets that shell out:

```json
{
  "build": { "command": "cargo build --release" },
  "test":  { "command": "cargo test" },
  "lint":  { "command": "cargo clippy -- -D warnings" }
}
```

## npm Workspaces + Nx

Nx works on top of npm workspaces. The root `package.json` declares workspaces:

```json
{
  "workspaces": ["packages/*", "apps/*"]
}
```

Nx auto-discovers these as projects. Each workspace can have its own `project.json` for custom targets.

## Task Dependencies

```
dependsOn: ["^build"]    // Run build on ALL dependencies first (upstream)
dependsOn: ["lint"]      // Run lint on THIS project first (same project)
dependsOn: []            // No dependencies, run immediately
```

The `^` prefix means "run this target on projects I depend on" (upstream). Without `^`, it means "run this target on the same project."

## Caching

Nx caches task outputs by default. Cache is invalidated when:
- Source files change (based on `inputs` config)
- Environment variables change (if configured)
- Dependencies change

```bash
# See cache status
npx nx build my-app --verbose

# Skip cache for a specific run
npx nx build my-app --skip-nx-cache

# Clear all cache
npx nx reset
```

## Adding a New Project

```bash
# With a generator (if plugin available)
npx nx g @nx/react:app my-app
npx nx g @nx/node:lib my-lib

# Manually
mkdir -p apps/my-app
# Add project.json with targets
# Add to root package.json workspaces if using npm workspaces
```

## Common Issues

### "Could not find Nx modules"

```bash
npm install    # or yarn install
```

Nx modules must be installed before any `npx nx` command.

### Hoisting Issues in Workspaces

When a package is hoisted to root `node_modules/` but its peer dependency is not:

```
Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'vite'
imported from node_modules/@tailwindcss/vite/dist/index.mjs
```

**Fix**: Add the peer dependency to root `package.json` `devDependencies`:

```json
{
  "devDependencies": {
    "vite": "^7.3.1"
  }
}
```

### Build Timeout

Nx builds can timeout on slow machines. Use direct commands for quick checks:

```bash
# Instead of waiting for full Nx orchestration:
npx tsc --noEmit                    # TypeScript check only
npx vite build                      # Vite build directly
cargo check                         # Rust check only
```

### Stale Cache

If a build passes in CI but fails locally (or vice versa):

```bash
npx nx reset                        # Clear all Nx cache
rm -rf node_modules/.cache          # Clear Vite/other caches
npm install                          # Reinstall
npx nx build <project>              # Fresh build
```

## Major Version Upgrades

Nx major upgrades (e.g., 20 -> 21) have a migration system:

```bash
npx nx migrate latest               # Generate migrations
npx nx migrate --run-migrations     # Apply migrations
```

**Important**: Don't jump multiple major versions at once. Go one major at a time (20 -> 21 -> 22). Each version may have breaking changes in workspace config, plugin APIs, or task runner behavior.

For safe minor bumps within current major:

```bash
npx npm-check-updates -u --target minor --filter "nx,@nx/*"
npm install
```

## Dev Startup Pattern

A common pattern for monorepos with a backend + frontend:

```bash
# scripts/dev.sh
#!/usr/bin/env bash
# Start backend, wait for health, then start frontend
npx nx dev backend &
BACKEND_PID=$!

# Wait for backend to be ready
until curl -s http://localhost:8081/api/health > /dev/null 2>&1; do
  sleep 1
done

npx nx dev frontend &
FRONTEND_PID=$!

# Trap to kill both on Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID 2>/dev/null" EXIT
wait
```

## Useful nx.json Patterns

### Shared Named Inputs

```json
{
  "namedInputs": {
    "default": ["{projectRoot}/**/*", "sharedGlobals"],
    "sharedGlobals": ["{workspaceRoot}/tsconfig.base.json"],
    "production": ["default", "!{projectRoot}/**/*.spec.*", "!{projectRoot}/**/*.test.*"],
    "rust": ["{workspaceRoot}/Cargo.toml", "{workspaceRoot}/Cargo.lock", "{projectRoot}/src/**/*"]
  }
}
```

### Project Tags for Constraints

```json
// project.json
{ "tags": ["scope:frontend", "type:app"] }

// nx.json -- enforce boundaries
{
  "constraints": [
    { "sourceTag": "scope:frontend", "onlyDependOnLibsWithTags": ["scope:frontend", "scope:shared"] }
  ]
}
```
