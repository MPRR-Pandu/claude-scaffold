---
name: security-dependency-management
description: Use when running npm/cargo audit, bumping package versions, fixing vulnerabilities, or resolving dependency issues.
---

# Security and Dependency Management

## When to Apply

- Running `npm audit` / `cargo audit` or fixing vulnerabilities
- Bumping package versions
- Resolving module resolution or hoisting errors
- Creating security-focused PRs

## npm Audit Workflow

```bash
# 1. Check vulnerabilities
npm audit

# 2. Auto-fix (use --legacy-peer-deps in workspaces)
npm audit fix --legacy-peer-deps

# 3. Verify remaining
npm audit
```

Some vulnerabilities have no upstream fix (transitive deps). Document these but don't force-break things.

## Bumping Packages Safely

```bash
# Check outdated (dry run)
npx npm-check-updates --packageFile package.json

# Bump everything to latest
npx npm-check-updates -u

# Bump within minor only (safe for build tools with breaking majors)
npx npm-check-updates -u --target minor

# Bump everything EXCEPT specific packages
npx npm-check-updates -u --reject "next,nx"

# Bump only specific package within minor
npx npm-check-updates -u --filter next --target minor
```

### Major Version Policy

- **Build tools** (Nx, Webpack, Vite major): `--target minor` -- major bumps break config
- **Frameworks** (Next.js, Angular major): `--target minor` -- major bumps break APIs
- **Libraries** (React, lodash, etc.): Latest is usually safe
- **Types** (`@types/*`): Latest is always safe
- **Dev tools** (ESLint, Prettier, TypeScript within major): Latest is usually safe

## npm Workspace Hoisting Issues

**Problem**: Package A (hoisted to root) depends on B, but B only exists in a workspace.

**Diagnostic**:
```bash
ls node_modules/PACKAGE/package.json          # Check root
ls workspace/node_modules/PACKAGE/package.json # Check workspace
```

**Fix**: Add the missing package to root `package.json` so npm hoists it.

## Cargo (Rust) Audit

```bash
# Install if needed
cargo install cargo-audit

# Run audit
cargo audit

# Fix what can be auto-fixed
cargo audit fix
```

## Verification After Bumps

Always verify after any dependency change:

```bash
# TypeScript projects
npx tsc --noEmit

# Rust projects
cargo check

# Build
npm run build  # or cargo build

# Tests
npm test       # or cargo test

# Final audit
npm audit
```

## PR Template for Security Updates

Include in the PR:
1. Audit before/after table (which CVEs fixed, which remain)
2. Package bump table (old -> new per package)
3. Major version decisions (why held back)
4. Remaining vulnerabilities ("no fix available" notation)
5. Verification confirmation (tsc, build, test pass)
