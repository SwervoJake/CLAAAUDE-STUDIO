#!/bin/bash
set -euo pipefail

# Only run in Claude Code remote sessions
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git -C "$(dirname "$0")/../.." rev-parse --show-toplevel 2>/dev/null || pwd)}"

echo "[session-start] ManyMoons Studio — initializing remote session"

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

echo "[session-start] Done"
