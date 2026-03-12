#!/usr/bin/env bash
# Blocks Edit/Write tool calls targeting locked project files.
# Exit code 2 = block the tool call (Claude Code convention).
# Called by PreToolUse hook in .claude/settings.json

shopt -s nocasematch

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Nothing to check if no tool input
if [[ -z "$TOOL_INPUT" ]]; then
  exit 0
fi

# Require python3
if ! command -v python3 &>/dev/null; then
  echo "[BLOCKED] python3 not found — cannot verify locked files. Install python3 or fix the hook." >&2
  exit 2
fi

# Extract file_path from the JSON tool input
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" \
  2>/dev/null || echo "")

LOCKED=("GDD.md" "tech-stack.md")

BASENAME=$(basename "$FILE_PATH")

for locked in "${LOCKED[@]}"; do
  if [[ "$BASENAME" == "$locked" ]]; then
    echo "[BLOCKED] Locked file — Blueprint approval required before editing $locked" >&2
    exit 2
  fi
done

exit 0
