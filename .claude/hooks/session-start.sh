#!/bin/bash
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || pwd)}"

echo "[session-start] ManyMoons Studio — initializing session"

# Ensure all scripts are executable
if [ -d "$PROJECT_DIR/scripts" ]; then
  chmod +x "$PROJECT_DIR/scripts/"*.sh 2>/dev/null || true
  echo "[session-start] Scripts marked executable"
fi

# Verify required memory-bank files exist
REQUIRED_FILES=(
  "memory-bank/GDD.md"
  "memory-bank/factions.md"
  "memory-bank/tech-stack.md"
  "memory-bank/milestones.md"
  "memory-bank/owner.md"
  "CLAUDE.md"
)

MISSING=0
for f in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$PROJECT_DIR/$f" ]; then
    echo "[session-start] WARNING: missing required file: $f"
    MISSING=$((MISSING + 1))
  fi
done

if [ "$MISSING" -eq 0 ]; then
  echo "[session-start] All required memory-bank files present"
else
  echo "[session-start] $MISSING required file(s) missing — agents may behave incorrectly"
fi

# Check for pending code reviews Blueprint needs to read
REVIEWS_FILE="$PROJECT_DIR/memory-bank/reviews.md"
if [ -f "$REVIEWS_FILE" ] && grep -q "\[PENDING\]" "$REVIEWS_FILE" 2>/dev/null; then
  PENDING_COUNT=$(grep -c "\[PENDING\]" "$REVIEWS_FILE" 2>/dev/null || echo "0")
  echo "[session-start] ⚠️  $PENDING_COUNT pending code review(s) in memory-bank/reviews.md — Blueprint should review before starting work"
fi

echo "[session-start] Done"
