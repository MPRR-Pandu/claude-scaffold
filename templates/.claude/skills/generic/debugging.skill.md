---
name: debugging
description: Use when diagnosing errors, crashes, unexpected behavior, or build failures in any project.
---

# Debugging

## When to Apply

- Build or compile errors
- Runtime crashes or unexpected behavior
- Test failures
- Performance issues
- "It works on my machine" problems

## Step-by-Step Debugging Process

1. **Reproduce**: Can you make the error happen consistently?
2. **Read the error**: The error message/stack trace is the most important clue
3. **Locate**: Which file and line? What function? What input?
4. **Isolate**: What's the smallest change that triggers/fixes the error?
5. **Understand**: Why does it fail? What assumption was wrong?
6. **Fix**: Change the code, not just the symptom
7. **Verify**: Does the fix work? Did it break anything else?
8. **Document**: Add to LESSONS.md if the root cause was non-obvious

## Common Error Categories

### Build / Compile Errors

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `Cannot find module X` | Missing dependency or wrong import path | `npm install X` or fix import |
| `ERR_MODULE_NOT_FOUND` | Workspace hoisting issue | Add dep to root package.json |
| `Type X is not assignable to Y` | TypeScript type mismatch | Check type definitions, add assertion |
| `Cannot find name X` | Missing import or undeclared variable | Add import or declare |
| `unresolved import` (Rust) | Missing `use` or Cargo dependency | Add to `Cargo.toml` or `use` statement |

### Runtime Errors

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| `undefined is not a function` | Calling method on wrong type | Check variable is what you expect |
| `Cannot read property X of undefined` | Null/undefined access | Add null check or optional chaining (`?.`) |
| `Maximum call stack exceeded` | Infinite recursion | Check base case, circular deps |
| `ECONNREFUSED` | Server not running | Start the backend/service first |
| `CORS error` | Cross-origin request blocked | Configure CORS on the server |

### React-Specific

| Error | Likely Cause | Fix |
|-------|-------------|-----|
| Infinite re-render | `useEffect` sets state that triggers itself | Check dependency array, use `useMemo` |
| Stale closure | Callback captures old state value | Use callback form of setState |
| Hydration mismatch | Server/client render different HTML | Ensure deterministic rendering |
| Missing key prop | List items without `key` | Add unique `key` to mapped elements |

## Diagnostic Commands

```bash
# Node.js
node --version                    # Check Node version
npm ls <package>                  # Show dependency tree for a package
npm why <package>                 # Why is this package installed?
npx tsc --noEmit                  # TypeScript errors without building

# Rust
cargo check                       # Fast compile check
cargo clippy                      # Lint with suggestions
RUST_BACKTRACE=1 cargo run        # Full backtrace on panic
cargo tree -d                     # Show duplicate dependencies

# Git
git diff                          # What changed?
git log --oneline -10             # Recent history
git bisect start                  # Binary search for breaking commit

# Network
curl -v http://localhost:8081/api/health  # Test API endpoint
lsof -ti :PORT                    # Find process on a port
kill -9 $(lsof -ti :PORT)         # Kill process on a port

# Process
ps aux | grep <name>              # Find running processes
top -l 1 | head -20               # System resource usage (macOS)
```

## Reading Stack Traces

1. **Start from the bottom** -- that's your code (the top is framework internals)
2. **Find your file** -- the first line referencing your source code is usually the culprit
3. **Note the line number** -- go to that exact line
4. **Read the error type** -- `TypeError`, `ReferenceError`, `SyntaxError` each tell you different things

```
Error: Cannot read property 'title' of undefined
    at filterTemplates (src/utils/filter.ts:15:25)    <-- YOUR CODE: line 15
    at useMemo (react-dom.js:1234)                     <-- Framework
    at renderWithHooks (react-dom.js:5678)             <-- Framework
```

## Binary Search for Bugs (git bisect)

When you know it worked before but not when it broke:

```bash
git bisect start
git bisect bad                    # Current version is broken
git bisect good <commit-hash>     # This version worked
# Git checks out a middle commit -- test it
git bisect good  # or  git bisect bad
# Repeat until git identifies the breaking commit
git bisect reset                  # When done
```

## When You're Stuck

1. Re-read the error message carefully -- every word matters
2. Search the exact error message (in quotes) online
3. Check if the issue is in your code or a dependency (`node_modules/` in stack trace = dependency)
4. Simplify: remove code until the error goes away, then add back piece by piece
5. Rubber duck: explain the problem out loud (or in a comment) step by step
6. Take a break -- fresh eyes catch what tired eyes miss
