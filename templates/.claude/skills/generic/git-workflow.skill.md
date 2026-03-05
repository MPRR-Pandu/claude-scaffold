---
name: git-workflow
description: Use when creating branches, commits, PRs, rebasing, or resolving merge conflicts in any project.
---

# Git Workflow

## When to Apply

- Creating feature branches, commits, or PRs
- Rebasing, merging, or resolving conflicts
- Managing release branches or hotfixes
- Working with forks and upstream remotes

## Branch Naming Convention

```
feat/short-description      # New features
fix/short-description       # Bug fixes
chore/short-description     # Maintenance, deps, config
docs/short-description      # Documentation only
refactor/short-description  # Code restructuring
test/short-description      # Test additions/fixes
```

## Commit Message Format

```
type: concise description of the change

Optional body explaining WHY, not WHAT.
The diff shows what changed -- the message explains the motivation.
```

Types: `feat`, `fix`, `chore`, `docs`, `refactor`, `test`, `perf`, `style`

**Good**: `fix: use deferredSearch for empty-state to prevent visual mismatch`
**Bad**: `fixed stuff` / `update file` / `wip`

## PR Workflow

```bash
# 1. Create branch from main
git checkout main && git pull
git checkout -b feat/my-feature

# 2. Make changes, commit
git add -A && git commit -m "feat: add search bar to template gallery"

# 3. Push and create PR
git push -u origin feat/my-feature
gh pr create --title "feat: add search bar" --body "## Summary\n- ..."

# 4. After review, rebase onto main (not merge)
git checkout feat/my-feature
git rebase origin/main
git push --force-with-lease
```

## Rebase vs Merge

- **Rebase**: Use for feature branches onto main. Keeps linear history.
- **Merge**: Use for long-lived branches or when history preservation matters.
- **Never**: Force push to `main`/`master` without explicit approval.

## Safe Force Push

```bash
# SAFE -- only pushes if remote hasn't diverged
git push --force-with-lease

# DANGEROUS -- overwrites remote unconditionally
git push --force  # avoid unless you know what you're doing
```

## Commit Amend Rules

Only amend when ALL conditions are met:
1. The commit was created by you in this session
2. The commit has NOT been pushed to remote
3. You're fixing the same logical change (not adding new work)

If the commit was already pushed, create a new commit instead.

## Resolving Merge Conflicts

```bash
# During rebase
git rebase origin/main
# ... conflicts appear ...
# Edit files to resolve, then:
git add <resolved-files>
git rebase --continue

# Abort if it goes wrong
git rebase --abort
```

## Stashing Work

```bash
git stash                    # Stash changes
git stash pop                # Apply and remove stash
git stash list               # See all stashes
git stash drop stash@{0}     # Remove a specific stash
```

## Useful Commands

```bash
git log --oneline -10            # Recent history
git diff --stat                  # Changed files summary
git diff origin/main...HEAD      # All changes since branching from main
git status --short               # Compact status
git remote -v                    # Show remotes
git branch -a                    # All branches (local + remote)
```
