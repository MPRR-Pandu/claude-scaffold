#!/usr/bin/env bash
set -euo pipefail

# ──────────────────────────────────────────────────────────────
# Claude Scaffold -- Plug-and-play AI assistant context for any project
#
# Usage:
#   ./init.sh                          # Interactive mode (prompts for values)
#   ./init.sh --name "My Project" \
#             --tech "React,Node,PostgreSQL" \
#             --build "npm run build" \
#             --test "npm test" \
#             --lint "npm run lint"    # Non-interactive mode
#
# What it does:
#   1. Creates CLAUDE.md (project entry point for AI assistants)
#   2. Creates LESSONS.md (shared knowledge base)
#   3. Creates .claude/ directory with:
#      - lessons.md (session-level corrections)
#      - skills/generic/ (universal skills -- git, security, frontend, etc.)
#      - skills/project/ (project-specific skills -- you add these)
#   4. Adds .claude/ to .gitignore (optional) or force-adds to git
# ──────────────────────────────────────────────────────────────

SCAFFOLD_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATES="$SCAFFOLD_DIR/templates"
TARGET="${TARGET_DIR:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

info()  { echo -e "${CYAN}[info]${NC} $1"; }
ok()    { echo -e "${GREEN}[ok]${NC} $1"; }
warn()  { echo -e "${YELLOW}[warn]${NC} $1"; }
err()   { echo -e "${RED}[error]${NC} $1"; }

# ── Parse arguments ──
PROJECT_NAME=""
TECH_STACK=""
BUILD_CMD=""
TEST_CMD=""
LINT_CMD=""
GIT_TRACK="ask"

while [[ $# -gt 0 ]]; do
  case $1 in
    --name)       PROJECT_NAME="$2"; shift 2 ;;
    --tech)       TECH_STACK="$2"; shift 2 ;;
    --build)      BUILD_CMD="$2"; shift 2 ;;
    --test)       TEST_CMD="$2"; shift 2 ;;
    --lint)       LINT_CMD="$2"; shift 2 ;;
    --git-track)  GIT_TRACK="yes"; shift ;;
    --no-git)     GIT_TRACK="no"; shift ;;
    --target)     TARGET="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: ./init.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --name NAME       Project name"
      echo "  --tech STACK       Comma-separated tech stack (e.g. 'React,Node,PostgreSQL')"
      echo "  --build CMD        Build command (e.g. 'npm run build')"
      echo "  --test CMD         Test command (e.g. 'npm test')"
      echo "  --lint CMD         Lint command (e.g. 'npm run lint')"
      echo "  --git-track        Force-add .claude/ to git (even if gitignored)"
      echo "  --no-git           Skip git operations entirely"
      echo "  --target DIR       Target directory (default: current directory)"
      echo "  -h, --help         Show this help"
      exit 0
      ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Interactive prompts for missing values ──
if [[ -z "$PROJECT_NAME" ]]; then
  # Try to auto-detect from package.json or directory name
  if [[ -f "$TARGET/package.json" ]]; then
    DEFAULT_NAME=$(python3 -c "import json; print(json.load(open('$TARGET/package.json')).get('name',''))" 2>/dev/null || echo "")
  elif [[ -f "$TARGET/Cargo.toml" ]]; then
    DEFAULT_NAME=$(grep '^name' "$TARGET/Cargo.toml" | head -1 | sed 's/name = "\(.*\)"/\1/' 2>/dev/null || echo "")
  else
    DEFAULT_NAME=$(basename "$(cd "$TARGET" && pwd)")
  fi
  read -rp "Project name [$DEFAULT_NAME]: " PROJECT_NAME
  PROJECT_NAME="${PROJECT_NAME:-$DEFAULT_NAME}"
fi

if [[ -z "$TECH_STACK" ]]; then
  # Auto-detect tech stack
  DETECTED=""
  [[ -f "$TARGET/package.json" ]] && DETECTED="Node.js"
  [[ -f "$TARGET/Cargo.toml" ]] && DETECTED="${DETECTED:+$DETECTED, }Rust"
  [[ -f "$TARGET/go.mod" ]] && DETECTED="${DETECTED:+$DETECTED, }Go"
  [[ -f "$TARGET/requirements.txt" ]] || [[ -f "$TARGET/pyproject.toml" ]] && DETECTED="${DETECTED:+$DETECTED, }Python"
  [[ -d "$TARGET/src" ]] && grep -rql "from 'react'" "$TARGET/src" 2>/dev/null && DETECTED="${DETECTED:+$DETECTED, }React"
  read -rp "Tech stack (comma-separated) [$DETECTED]: " TECH_STACK
  TECH_STACK="${TECH_STACK:-$DETECTED}"
fi

if [[ -z "$BUILD_CMD" ]]; then
  DEFAULT_BUILD=""
  [[ -f "$TARGET/package.json" ]] && DEFAULT_BUILD="npm run build"
  [[ -f "$TARGET/Cargo.toml" ]] && DEFAULT_BUILD="cargo build"
  [[ -f "$TARGET/Makefile" ]] && DEFAULT_BUILD="make build"
  read -rp "Build command [$DEFAULT_BUILD]: " BUILD_CMD
  BUILD_CMD="${BUILD_CMD:-$DEFAULT_BUILD}"
fi

if [[ -z "$TEST_CMD" ]]; then
  DEFAULT_TEST=""
  [[ -f "$TARGET/package.json" ]] && DEFAULT_TEST="npm test"
  [[ -f "$TARGET/Cargo.toml" ]] && DEFAULT_TEST="cargo test"
  read -rp "Test command [$DEFAULT_TEST]: " TEST_CMD
  TEST_CMD="${TEST_CMD:-$DEFAULT_TEST}"
fi

if [[ -z "$LINT_CMD" ]]; then
  DEFAULT_LINT=""
  [[ -f "$TARGET/package.json" ]] && DEFAULT_LINT="npm run lint"
  [[ -f "$TARGET/Cargo.toml" ]] && DEFAULT_LINT="cargo clippy -- -D warnings"
  read -rp "Lint command [$DEFAULT_LINT]: " LINT_CMD
  LINT_CMD="${LINT_CMD:-$DEFAULT_LINT}"
fi

echo ""
info "Initializing Claude scaffold for: $PROJECT_NAME"
info "Target: $(cd "$TARGET" && pwd)"
echo ""

# ── Generate CLAUDE.md ──
if [[ -f "$TARGET/CLAUDE.md" ]]; then
  warn "CLAUDE.md already exists -- skipping (won't overwrite)"
else
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{TECH_STACK}}|$TECH_STACK|g" \
    -e "s|{{BUILD_CMD}}|$BUILD_CMD|g" \
    -e "s|{{TEST_CMD}}|$TEST_CMD|g" \
    -e "s|{{LINT_CMD}}|$LINT_CMD|g" \
    -e "s|{{DATE}}|$(date +%Y-%m-%d)|g" \
    "$TEMPLATES/CLAUDE.md.tmpl" > "$TARGET/CLAUDE.md"
  ok "Created CLAUDE.md"
fi

# ── Generate LESSONS.md ──
if [[ -f "$TARGET/LESSONS.md" ]]; then
  warn "LESSONS.md already exists -- skipping (won't overwrite)"
else
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{DATE}}|$(date +%Y-%m-%d)|g" \
    "$TEMPLATES/LESSONS.md.tmpl" > "$TARGET/LESSONS.md"
  ok "Created LESSONS.md"
fi

# ── Generate AGENT.md (rules for agents running inside workflows) ──
if [[ -f "$TARGET/AGENT.md" ]]; then
  warn "AGENT.md already exists -- skipping (won't overwrite)"
else
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    "$TEMPLATES/AGENT.md.tmpl" > "$TARGET/AGENT.md"
  ok "Created AGENT.md"
fi

# ── Generate NOPE.md (dead ends / failed approaches) ──
if [[ -f "$TARGET/NOPE.md" ]]; then
  warn "NOPE.md already exists -- skipping (won't overwrite)"
else
  cp "$TEMPLATES/NOPE.md.tmpl" "$TARGET/NOPE.md"
  ok "Created NOPE.md"
fi

# ── Generate docs/AI-WORKFLOW.md (how agents should operate) ──
mkdir -p "$TARGET/docs"
if [[ -f "$TARGET/docs/AI-WORKFLOW.md" ]]; then
  warn "docs/AI-WORKFLOW.md already exists -- skipping (won't overwrite)"
else
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{BUILD_CMD}}|$BUILD_CMD|g" \
    -e "s|{{TEST_CMD}}|$TEST_CMD|g" \
    -e "s|{{LINT_CMD}}|$LINT_CMD|g" \
    "$TEMPLATES/docs/AI-WORKFLOW.md.tmpl" > "$TARGET/docs/AI-WORKFLOW.md"
  ok "Created docs/AI-WORKFLOW.md"
fi

# ── Copy AGENTS.md template to project root (for per-directory use) ──
if [[ ! -f "$TARGET/AGENTS.md.template" ]]; then
  sed \
    -e "s|{{SUBPROJECT_NAME}}|[Subdirectory Name]|g" \
    "$TEMPLATES/AGENTS.md.tmpl" > "$TARGET/AGENTS.md.template"
  ok "Created AGENTS.md.template (copy into subdirectories and customize)"
fi

# ── Create .claude/ directory ──
mkdir -p "$TARGET/.claude/skills/generic"
mkdir -p "$TARGET/.claude/skills/project"

# Session-level lessons
if [[ ! -f "$TARGET/.claude/lessons.md" ]]; then
  sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    "$TEMPLATES/.claude/lessons.md.tmpl" > "$TARGET/.claude/lessons.md"
  ok "Created .claude/lessons.md"
else
  warn ".claude/lessons.md already exists -- skipping"
fi

# Copy generic skills
GENERIC_COUNT=0
for skill in "$TEMPLATES/.claude/skills/generic/"*.skill.md; do
  BASENAME=$(basename "$skill")
  if [[ ! -f "$TARGET/.claude/skills/generic/$BASENAME" ]]; then
    cp "$skill" "$TARGET/.claude/skills/generic/$BASENAME"
    GENERIC_COUNT=$((GENERIC_COUNT + 1))
  fi
done
ok "Copied $GENERIC_COUNT generic skills to .claude/skills/generic/"

# Copy project skill templates
for tmpl in "$TEMPLATES/.claude/skills/project/"*; do
  BASENAME=$(basename "$tmpl")
  if [[ ! -f "$TARGET/.claude/skills/project/$BASENAME" ]]; then
    cp "$tmpl" "$TARGET/.claude/skills/project/$BASENAME"
  fi
done
ok "Copied project skill templates to .claude/skills/project/"

# ── Git integration ──
if [[ "$GIT_TRACK" == "ask" ]] && [[ -d "$TARGET/.git" ]]; then
  echo ""
  read -rp "Force-add .claude/ to git (recommended for team sharing)? [Y/n]: " ANSWER
  if [[ "$ANSWER" =~ ^[Nn] ]]; then
    GIT_TRACK="no"
  else
    GIT_TRACK="yes"
  fi
fi

if [[ "$GIT_TRACK" == "yes" ]] && [[ -d "$TARGET/.git" ]]; then
  (cd "$TARGET" && git add -f .claude/ CLAUDE.md LESSONS.md AGENT.md NOPE.md AGENTS.md.template docs/AI-WORKFLOW.md 2>/dev/null || true)
  ok "Force-added all scaffold files to git staging"
fi

echo ""
echo -e "${GREEN}Done!${NC} Claude scaffold initialized for ${CYAN}$PROJECT_NAME${NC}"
echo ""
echo "Directory structure:"
echo ""
echo "  Root files:"
echo "    CLAUDE.md                            # AI entry point -- project overview and rules"
echo "    AGENT.md                             # Rules for agents running inside workflows"
echo "    LESSONS.md                           # Shared lessons learned (grows over time)"
echo "    NOPE.md                              # Dead ends -- approaches that don't work"
echo "    AGENTS.md.template                   # Copy into subdirectories for local agent context"
echo ""
echo "  docs/"
echo "    AI-WORKFLOW.md                       # How agents should operate step-by-step"
echo ""
echo "  .claude/"
echo "    lessons.md                           # Session-level corrections"
echo "    skills/"
echo "      generic/                           # Universal skills (10 files)"
echo "        agentic-patterns.skill.md        #   Multi-step tasks, error recovery, subagents"
echo "        code-review-checklist.skill.md   #   Pre-commit checks, anti-patterns"
echo "        debugging.skill.md               #   Error diagnosis, stack traces, diagnostics"
echo "        frontend-patterns.skill.md       #   React hooks, search bars, CSS theming"
echo "        git-workflow.skill.md            #   Branches, commits, PRs, rebase"
echo "        nx-monorepo.skill.md             #   Nx commands, caching, workspace config"
echo "        prompt-engineering.skill.md      #   Writing CLAUDE.md, skills, agent rules"
echo "        security-dependency-management.skill.md  # npm audit, version bumps"
echo "        task-decomposition.skill.md      #   Breaking down complex tasks"
echo "        testing-strategy.skill.md        #   What to test, AAA pattern, fixtures"
echo "      project/                           # YOUR project-specific skills go here"
echo "        _README.md                       #   How to add skills"
echo "        _template.skill.md               #   Blank template to copy"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md -- fill in architecture, commands, and critical rules"
echo "  2. Edit AGENT.md -- customize scope boundaries and output formatting"
echo "  3. Copy AGENTS.md.template into subdirectories (apps/, packages/, etc.)"
echo "  4. Add project-specific skills to .claude/skills/project/"
echo "  5. As you work, lessons accumulate in LESSONS.md and NOPE.md grows"
echo ""
