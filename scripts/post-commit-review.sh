#!/usr/bin/env bash
# PostToolUse hook — fires build-verifier agent after every git commit

# Always exit 0 — PostToolUse failures should never disrupt Claude
set +e

# Only act on Bash tool calls
if [[ "${CLAUDE_TOOL_NAME:-}" != "Bash" ]]; then
  exit 0
fi

# Check if the bash command was a git commit (any variant)
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"
if [[ -z "$TOOL_INPUT" ]]; then
  exit 0
fi

if ! command -v python3 &>/dev/null; then
  exit 0
fi

BASH_CMD=$(echo "$TOOL_INPUT" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" \
  2>/dev/null || echo "")

# Only trigger on git commit commands
if ! echo "$BASH_CMD" | grep -qE "git\s+commit"; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git -C "$(dirname "$0")/.." rev-parse --show-toplevel 2>/dev/null || pwd)}"

# Get the latest commit info
cd "$PROJECT_DIR" 2>/dev/null || exit 0

SHORT_SHA=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
SUBJECT=$(git log -1 --format="%s" 2>/dev/null || echo "unknown")
FILES_CHANGED=$(git diff --name-only HEAD~1 HEAD 2>/dev/null | wc -l | tr -d ' ')
DIFF=$(git diff HEAD~1 HEAD 2>/dev/null | head -500)

TODAY=$(date +%Y-%m-%d 2>/dev/null || echo "unknown")

echo "[post-commit-review] Reviewing commit $SHORT_SHA: $SUBJECT" >&2

# Write a pending placeholder immediately so Blueprint sees it even if agent fails
REVIEWS_FILE="$PROJECT_DIR/memory-bank/reviews.md"
if [[ -f "$REVIEWS_FILE" ]]; then
  cat >> "$REVIEWS_FILE" <<ENTRY

### [PENDING] Commit: $SHORT_SHA — $SUBJECT
**Date:** $TODAY
**Files changed:** $FILES_CHANGED
**Reviewer:** build-verifier (pending — agent dispatched)

**Findings:**
- Review in progress

**Summary:** Agent dispatched for review.
ENTRY
fi

# Note: In production, this is where you would dispatch the build-verifier agent.
# Claude Code does not currently support spawning agents from hooks directly.
# Blueprint manually invokes build-verifier via: Agent tool with build-verifier subagent_type.
# The placeholder above ensures Blueprint sees the commit needs review.

echo "[post-commit-review] Placeholder written to reviews.md — Blueprint will dispatch build-verifier." >&2

exit 0
