# Claude Automation Suite — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add four layers of Claude Code automation — protective hooks, agent skills, MCP connections, and automated commit review — all routed through Blueprint so Jacob receives one voice in Slack.

**Architecture:** Layered delivery (A → B → D → C). Each layer commits independently. Layer D (MCPs) requires environment variables Jacob sets locally; all other layers need no external credentials.

**Tech Stack:** Bash shell scripts, JSON (Claude Code settings + MCP config), Markdown (skill + agent files)

**Spec:** `docs/superpowers/specs/2026-03-12-claude-automation-suite-design.md`

---

## Chunk 1: Layer A — Protective Hooks

**Files:**
- Modify: `.claude/hooks/session-start.sh`
- Create: `scripts/check-locked-files.sh`
- Create: `memory-bank/owner.md`
- Modify: `.claude/settings.json`

---

### Task 1: Create the locked-file guard script

This script is called by a PreToolUse hook before any Edit or Write tool call. If the target file is `GDD.md` or `tech-stack.md`, it exits with code 2 — which tells Claude Code to block the tool call and show the message.

- [ ] **Step 1: Create the script**

Create `scripts/check-locked-files.sh` with this exact content:

```bash
#!/usr/bin/env bash
# Blocks Edit/Write tool calls targeting locked project files.
# Exit code 2 = block the tool call (Claude Code convention).
# Called by PreToolUse hook in .claude/settings.json

set -euo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Extract file_path from the JSON tool input
FILE_PATH=$(echo "$TOOL_INPUT" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('file_path',''))" \
  2>/dev/null || echo "")

LOCKED=("GDD.md" "tech-stack.md")

for locked in "${LOCKED[@]}"; do
  if [[ "$FILE_PATH" == *"$locked"* ]]; then
    echo "[BLOCKED] Locked file — Blueprint approval required before editing $locked"
    exit 2
  fi
done

exit 0
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/check-locked-files.sh
```

- [ ] **Step 3: Verify it blocks correctly**

```bash
# Simulate what Claude Code passes as CLAUDE_TOOL_INPUT
export CLAUDE_TOOL_INPUT='{"file_path": "memory-bank/GDD.md", "old_string": "x", "new_string": "y"}'
bash scripts/check-locked-files.sh
echo "Exit code: $?"
```

Expected output:
```
[BLOCKED] Locked file — Blueprint approval required before editing GDD.md
Exit code: 2
```

- [ ] **Step 4: Verify it passes safe files**

```bash
export CLAUDE_TOOL_INPUT='{"file_path": "memory-bank/progress.md", "old_string": "x", "new_string": "y"}'
bash scripts/check-locked-files.sh
echo "Exit code: $?"
```

Expected output:
```
Exit code: 0
```

---

### Task 2: Fix the SessionStart hook

Right now the hook exits immediately unless `CLAUDE_CODE_REMOTE=true`, which means local sessions get no file verification. We're also adding `owner.md` to the required files list and a check for pending code reviews.

- [ ] **Step 1: Replace the full file content**

Open `.claude/hooks/session-start.sh` and replace its entire content with:

```bash
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
```

- [ ] **Step 2: Verify it runs locally**

```bash
bash .claude/hooks/session-start.sh
```

Expected: prints file verification output without requiring `CLAUDE_CODE_REMOTE=true`.

- [ ] **Step 3: Verify it warns about missing owner.md** (owner.md doesn't exist yet — that's Task 3)

```bash
bash .claude/hooks/session-start.sh
```

Expected: `WARNING: missing required file: memory-bank/owner.md`

---

### Task 3: Create the owner context document

This is a template Jacob fills in. The file itself is what matters — agents are instructed to read it.

- [ ] **Step 1: Create `memory-bank/owner.md`**

```markdown
# Owner Context — Jacob

> Every agent reads this file before starting any task.
> Keep it current — this is your voice in every session.

Last updated: 2026-03-12

---

## My Mission

[Write 2-3 sentences about why you're building ManyMoons and what success means to you personally.]

---

## What I'm Building and Why

ManyMoons is an Oasis/SAO-inspired social-first futuristic town hub with dungeon side activity — single-player, Windows PC. The goal is a game that feels like a living world worth returning to, not just a dungeon runner with a hub tacked on.

---

## My Priorities Right Now (M0)

1. Get a stable, repeatable Windows build that passes the smoke test
2. Document everything cleanly so future agents have full context
3. Don't add scope — M0 is about foundation, not features

---

## How I Like to Work

- One voice in Slack: Blueprint escalates to me, no other agent pings me directly
- Show me problems as soon as you find them — I'd rather know early
- Commit often at natural milestones, not in one big dump at the end
- If you're uncertain about scope, run scope-check before building

---

## Standing Context for All Agents

- The GDD is locked. If something isn't in it, flag it to Blueprint — don't build it
- Blueprint is the final decision-maker on all technical choices
- Stability > features, always
- This is a solo dev project with AI agents. Clarity in documentation is what keeps it coherent
```

- [ ] **Step 2: Verify the hook now passes**

```bash
bash .claude/hooks/session-start.sh
```

Expected: `All required memory-bank files present` (no warnings about owner.md).

---

### Task 4: Add PreToolUse hook to settings.json

This wires the `check-locked-files.sh` script into every Edit and Write tool call.

- [ ] **Step 1: Replace `.claude/settings.json` with the updated version**

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/check-locked-files.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/notify-slack.sh notification 'Blueprint needs your attention' 'An agent is waiting for your input or approval. Check your Claude Code session.'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/notify-slack.sh stop 'Session ended' 'A Claude Code agent session has completed. Review progress.md for current status.'"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('Valid JSON')"
```

Expected: `Valid JSON`

- [ ] **Step 3: Commit Layer A**

```bash
git add .claude/hooks/session-start.sh scripts/check-locked-files.sh memory-bank/owner.md .claude/settings.json
git commit -m "feat(automation): Layer A — session hooks + GDD lock guard + owner context"
```

---

## Chunk 2: Layer B — Skills + Agent Updates

**Files:**
- Create: `.claude/skills/adr/SKILL.md`
- Create: `.claude/skills/milestone-gate/SKILL.md`
- Create: `.claude/skills/escalate/SKILL.md`
- Create: `.claude/skills/progress-update/SKILL.md`
- Create: `.claude/skills/scope-check/SKILL.md`
- Modify: `.claude/agents/systems-agent.md`
- Modify: `.claude/agents/world-agent.md`
- Modify: `.claude/agents/npc-narrative-agent.md`
- Modify: `.claude/agents/combat-agent.md`
- Modify: `.claude/agents/polish-qa-agent.md`

---

### Task 5: Create the `adr` skill

Blueprint uses this to append a correctly-numbered Architecture Decision Record to `tech-stack.md`.

- [ ] **Step 1: Create `.claude/skills/adr/SKILL.md`**

```markdown
---
name: adr
description: Append a correctly-numbered Architecture Decision Record to memory-bank/tech-stack.md. Use whenever Blueprint makes a significant technical decision (hard to reverse, affects multiple agents, or changes existing architecture).
---

You are documenting an Architecture Decision Record for the ManyMoons project. Follow these steps exactly:

1. Read `memory-bank/tech-stack.md` in full.
2. Find the highest existing ADR number (e.g., if the last is ADR-006, yours will be ADR-007).
3. Ask the user for: the decision title, what was decided, why, what tradeoffs are accepted, and a review date (or use "M1 complete" if no specific date).
4. Append this block to the ADR log section of `memory-bank/tech-stack.md`:

```
### ADR-[N]: [Title]
**Decision:** [What was chosen]
**Rationale:** [Why]
**Tradeoffs accepted:** [What we give up]
**Review date:** [When to revisit]
```

5. Confirm the new ADR number and title were written correctly.
6. Remind Blueprint to commit: `git add memory-bank/tech-stack.md && git commit -m "docs(adr): ADR-[N] [title]"`
```

- [ ] **Step 2: Verify the skill is discoverable**

```bash
ls .claude/skills/adr/SKILL.md
```

Expected: file exists.

---

### Task 6: Create the `milestone-gate` skill

Blueprint runs the formal acceptance checklist and posts the result to Slack. This is one of only two skills allowed to post to Slack.

- [ ] **Step 1: Create `.claude/skills/milestone-gate/SKILL.md`**

```markdown
---
name: milestone-gate
description: Run the formal acceptance checklist for the current milestone. Walks Blueprint through each criterion (pass/fail), updates memory-bank/progress.md, and posts the gate result to #claaaude-studio via Slack. Only Blueprint invokes this.
disable-model-invocation: true
---

You are Blueprint running a formal milestone gate. This is a sequential checklist — do not skip items or assume passes.

**Step 1: Identify the current milestone**
Read `memory-bank/progress.md` to confirm which milestone is active (M0, M1, M2, or M3).

**Step 2: Pull the acceptance checklist**
Read `memory-bank/milestones.md` and extract every acceptance criterion for the active milestone.

**Step 3: Walk each criterion**
For each criterion, ask: "Has this been verified? (pass/fail/skip-with-reason)"
Record every response.

**Step 4: Compute the result**
- APPROVED: all criteria pass (or skipped with documented reason)
- HOLD: one or more criteria fail

**Step 5: Update progress.md**
In `memory-bank/progress.md`, update the Milestone Acceptance Checklist section to reflect current pass/fail status.

**Step 6: Post to Slack**
Use the Slack MCP to post to channel C0AKGFLLJ6A (#claaaude-studio):

```
*[ManyMoons / Milestone Gate]* [MILESTONE] — [APPROVED ✅ / HOLD ❌]

Criteria: [N] total | [N] passed | [N] failed | [N] skipped

[If HOLD:]
Blocking failures:
• [criterion]: [what failed]

[If APPROVED:]
All acceptance criteria passed. Awaiting Jacob's go/no-go to proceed to [next milestone].
```

**Step 7: Stop and wait**
Do not proceed to the next milestone without explicit Jacob approval in the chat interface.
```

- [ ] **Step 2: Verify**

```bash
ls .claude/skills/milestone-gate/SKILL.md
```

---

### Task 7: Create the `escalate` skill

Blueprint uses this when it needs Jacob to make a decision. The only other skill allowed to post to Slack.

- [ ] **Step 1: Create `.claude/skills/escalate/SKILL.md`**

```markdown
---
name: escalate
description: Format and send a Jacob escalation to #claaaude-studio. Use when Blueprint cannot determine the right path forward without Jacob's input (Rule 3). Only escalate when the decision has real consequences — not for trivial questions.
disable-model-invocation: true
---

You are Blueprint preparing an escalation to Jacob. Follow this format exactly — no improvising.

**Step 1: Gather the escalation content**
Ask Blueprint (or derive from context):
- What decision is needed? (one sentence)
- What is Option A? (what it is + consequence)
- What is Option B? (what it is + consequence)
- What is your recommendation and why?
- What happens if Jacob doesn't decide today? (cost of delay)

**Step 2: Post to Slack**
Use the Slack MCP to post to channel C0AKGFLLJ6A (#claaaude-studio):

```
*ESCALATION TO JACOB*

*Decision needed:* [one sentence]

*Option A:* [what + consequence]
*Option B:* [what + consequence]

*Blueprint recommends:* [which + why, 1-2 sentences]

*Cost of delay:* [what happens if this waits]
```

**Step 3: Wait**
Do not proceed with either option until Jacob responds in the chat interface. Record Jacob's decision in `memory-bank/tech-stack.md` as an ADR entry if it is architectural (use the `adr` skill).
```

- [ ] **Step 2: Verify**

```bash
ls .claude/skills/escalate/SKILL.md
```

---

### Task 8: Create the `progress-update` skill

Orchestrator uses this to update `memory-bank/progress.md` in the correct format.

- [ ] **Step 1: Create `.claude/skills/progress-update/SKILL.md`**

```markdown
---
name: progress-update
description: Update memory-bank/progress.md with current task status. Use at the end of every work cycle or when a task status changes. Orchestrator's primary tool for keeping the studio log accurate.
---

You are updating the ManyMoons studio progress log. Follow these steps:

**Step 1: Read the current state**
Read `memory-bank/progress.md` in full.

**Step 2: Determine what changed**
Ask or derive from context:
- Any tasks moving from Active to Completed?
- Any new tasks to add to Active?
- Any new blockers?
- Any backlog items to add?

**Step 3: Apply changes**
- Move completed tasks from the Active Tasks table to the Completed This Milestone table (add today's date)
- Add new Active tasks with correct agent assignment and status
- Update the "Last updated" date at the top to today's date (format: YYYY-MM-DD)
- Add blockers to the Notes section if any

**Step 4: Do not touch the Milestone Acceptance Checklist**
That section is owned by the `milestone-gate` skill. Do not modify it here.

**Step 5: Confirm**
Report what was added, moved, or changed. If any task moved to Completed, ask whether a commit is needed.
```

- [ ] **Step 2: Verify**

```bash
ls .claude/skills/progress-update/SKILL.md
```

---

### Task 9: Create the `scope-check` skill

All agents use this to verify a proposed feature or task is within the v1 GDD before building.

- [ ] **Step 1: Create `.claude/skills/scope-check/SKILL.md`**

```markdown
---
name: scope-check
description: Verify whether a proposed feature or task is within the ManyMoons v1 GDD scope. All agents should run this before starting any new work that wasn't explicitly assigned by Orchestrator. Claude invokes this automatically — users can also invoke it directly.
user-invocable: false
---

You are performing a scope check against the ManyMoons v1 GDD.

**Step 1: Read the GDD**
Read `memory-bank/GDD.md` in full.

**Step 2: Evaluate the proposed feature or task**
The feature to check is: [the task or feature the calling agent was about to build]

**Step 3: Return one of these verdicts:**

**IN SCOPE ✅**
> "[Feature]" is within v1 scope. Relevant GDD section: [section name + quote].
> Proceed.

**OUT OF SCOPE 🚫**
> "[Feature]" is not in the v1 GDD. Do not build it.
> Closest in-scope equivalent: [what IS in scope that might address the same need, or "none"].
> Log this request in memory-bank/progress.md under "Backlog (out of scope for current milestone)" and surface to Blueprint.

**UNCLEAR — ESCALATE ⚠️**
> "[Feature]" is ambiguous in the GDD. Cannot determine scope without Blueprint clarification.
> Do not build until Blueprint decides.
```

- [ ] **Step 2: Verify**

```bash
ls .claude/skills/scope-check/SKILL.md
```

---

### Task 10: Add Supabase instruction to all specialist agents

Each specialist agent gets a "Before you start" block instructing them to query the Vault.

- [ ] **Step 1: Add to `systems-agent.md`**

Append this block before the `## Escalation Triggers` section:

```markdown
---

## Before Starting Any Task

Query the Supabase Vault for relevant research before building anything:
1. Connect using the Supabase MCP (project: `wofvwgvaoqwcfgleirne`)
2. Query `research_entries` for entries relevant to your domain (player controller, input, save/load, physics, game loop)
3. Use the results to inform your approach before writing any Blueprint code
4. If no relevant entries exist, proceed with existing GDD and tech-stack guidance

```

- [ ] **Step 2: Add identical block to `world-agent.md`**

Append before `## Escalation Triggers` (or at the end if no such section), adjusting the domain description:

```markdown
---

## Before Starting Any Task

Query the Supabase Vault for relevant research before building anything:
1. Connect using the Supabase MCP (project: `wofvwgvaoqwcfgleirne`)
2. Query `research_entries` for entries relevant to your domain (level design, environment art, lighting, hub layout, dungeon rooms)
3. Use the results to inform your approach before placing any assets
4. If no relevant entries exist, proceed with existing GDD and tech-stack guidance

```

- [ ] **Step 3: Add identical block to `npc-narrative-agent.md`**

Domain: `NPC dialogue, faction interactions, reputation system, narrative scripting`

- [ ] **Step 4: Add identical block to `combat-agent.md`**

Domain: `combat mechanics, enemy AI, boss design, hitboxes, damage systems`

- [ ] **Step 5: Add identical block to `polish-qa-agent.md`**

Domain: `QA testing, bug classification, performance validation, acceptance criteria`

- [ ] **Step 6: Verify all five files were modified**

```bash
grep -l "Supabase Vault" .claude/agents/*.md
```

Expected: all five specialist agent files listed.

- [ ] **Step 7: Commit Layer B**

```bash
git add .claude/skills/ .claude/agents/
git commit -m "feat(automation): Layer B — 5 skills + Supabase instructions for all specialist agents"
```

---

## Chunk 3: Layer D + C — MCP Connections, Build-Verifier, Commit Hook

**Files:**
- Create: `.mcp.json`
- Create: `.claude/agents/build-verifier.md`
- Create: `scripts/post-commit-review.sh`
- Create: `memory-bank/reviews.md`
- Modify: `.claude/settings.json` (add PostToolUse hook)

---

### Task 11: Create `.mcp.json`

This makes Supabase and Slack available to all agents in Claude Code. Tokens are read from environment variables — they never go in the file.

- [ ] **Step 1: Create `.mcp.json` at the repo root**

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": [
        "-y",
        "@supabase/mcp-server-supabase@latest",
        "--access-token",
        "${SUPABASE_ACCESS_TOKEN}"
      ],
      "env": {
        "SUPABASE_PROJECT_ID": "wofvwgvaoqwcfgleirne"
      }
    },
    "slack": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-slack"
      ],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      }
    }
  }
}
```

- [ ] **Step 2: Add `.mcp.json` to `.gitignore` check — it should NOT be ignored**

```bash
git check-ignore -v .mcp.json
```

Expected: no output (file is not ignored — it should be committed so the whole team inherits the config).

- [ ] **Step 3: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('.mcp.json')); print('Valid JSON')"
```

Expected: `Valid JSON`

- [ ] **Step 4: Set your local environment variables**

Jacob must set these in their shell profile (`.bashrc`, `.zshrc`, or Windows environment variables). Claude Code will read them from the environment:

```bash
# Add to your shell profile — do NOT commit these values
export SUPABASE_ACCESS_TOKEN="your-supabase-personal-access-token"
export SLACK_BOT_TOKEN="xoxb-your-slack-bot-token"
export SLACK_TEAM_ID="your-slack-team-id"
```

Note: Since Jacob already has both MCPs enabled in Claude Desktop, these token values are already configured — check Claude Desktop's MCP config for the exact values to copy.

- [ ] **Step 5: Commit Layer D**

```bash
git add .mcp.json
git commit -m "feat(automation): Layer D — MCP connections for Supabase Vault and Slack"
```

---

### Task 12: Create the build-verifier agent

Polish/QA dispatches this agent after accepting a commit review trigger. It writes findings to `memory-bank/reviews.md` — it never posts to Slack directly.

- [ ] **Step 1: Create `memory-bank/reviews.md`**

```markdown
# Code Review Log

All commit reviews are appended here by the post-commit hook.
Blueprint reads pending reviews at session start and escalates to Jacob if needed.

**Status key:** `[PENDING]` = Blueprint has not reviewed | `[REVIEWED]` = Blueprint has read | `[ESCALATED]` = Jacob was notified

---
```

- [ ] **Step 2: Create `.claude/agents/build-verifier.md`**

```markdown
---
name: build-verifier
description: Use this agent after a git commit to review the diff for naming convention violations, locked file edits, scope drift, and commit message quality. Writes a structured report to memory-bank/reviews.md. Does NOT post to Slack — Blueprint reads reviews.md and escalates if needed.
---

# Build Verifier — Commit Code Reviewer
## Role: Code Quality Gate | Reports to: Polish/QA → Orchestrator → Blueprint

---

## Who I Am

I review every commit for the four things agents most commonly get wrong: naming conventions, locked file edits, scope drift, and unclear commit messages. I do not block commits — I report findings so Blueprint can act.

I write my findings to `memory-bank/reviews.md`. I never post to Slack. That is Blueprint's job.

---

## What I Check

### 1. Asset Naming Conventions
Check all changed `.uasset` and `.umap` files against the locked naming table:

| Asset Type | Required Prefix |
|-----------|----------------|
| Blueprint Actor | `BP_` |
| Blueprint Component | `BPC_` |
| Blueprint Interface | `BPI_` |
| Widget Blueprint | `WBP_` |
| Static Mesh | `SM_` |
| Skeletal Mesh | `SK_` |
| Material | `M_` |
| Material Instance | `MI_` |
| Map/Level | `L_` |
| Data Table | `DT_` |
| Enum | `E_` |

Exceptions: `BP_FirstPersonCharacter` and other template assets are exempt.

### 2. Locked File Edits
Check whether `GDD.md` or `tech-stack.md` appear in the diff. If yes, flag as a potential violation — these require Blueprint approval. (The PreToolUse hook should have caught these, but verify anyway.)

### 3. Scope Drift
Read the diff summary. If any new Blueprint, script, or asset appears to implement a feature not described in the GDD, flag it with the specific feature and the closest GDD section.

### 4. Commit Message Quality
The commit message should: describe what changed (not just "update"), reference the affected system, use conventional commits format (`feat:`, `fix:`, `docs:`, `chore:`). Flag if it's too vague (e.g., "misc changes", "wip", "fix stuff").

---

## How to Run a Review

**Step 1:** Read the diff
```bash
git log -1 --oneline
git diff HEAD~1..HEAD --stat
git diff HEAD~1..HEAD --name-only
```

**Step 2:** For each changed file, apply the four checks above.

**Step 3:** Write a structured report to `memory-bank/reviews.md`:

```
## [PENDING] Review — [YYYY-MM-DD HH:MM UTC]
**Commit:** `[short hash]` — [commit message]

**Changed files:**
[git diff --stat output]

**Findings:**
[For each check:]
- Naming conventions: ✅ Clean / ⚠️ [violation details]
- Locked files: ✅ None touched / ⚠️ [which file + why it was changed]
- Scope drift: ✅ In scope / ⚠️ [what looks out of scope]
- Commit message: ✅ Clear / ⚠️ [what's unclear]

**Overall:** ✅ No issues / ⚠️ [N] issue(s) found — Blueprint review recommended

---
```

**Step 4:** If any `⚠️` findings exist, also append one line to `memory-bank/progress.md` under Active Tasks:

```
| Review pending: `[short hash]` | Build Verifier | Needs Blueprint review |
```

**Step 5:** Stop. Do not post to Slack. Do not take further action. Blueprint reads `reviews.md`.

---

## Escalation

I never escalate directly to Jacob. My escalation path is:
Build Verifier → reviews.md → Blueprint reads at session start → Blueprint uses `escalate` skill if Jacob needs to know
```

- [ ] **Step 3: Verify both files exist**

```bash
ls memory-bank/reviews.md .claude/agents/build-verifier.md
```

---

### Task 13: Create the post-commit review hook script

This lightweight shell script fires after every `git commit` Bash call. It captures the diff summary, runs a quick naming check, and writes to `reviews.md` — without calling Claude (keeping it fast and cheap).

- [ ] **Step 1: Create `scripts/post-commit-review.sh`**

```bash
#!/usr/bin/env bash
# Fires after git commit tool calls (PostToolUse hook).
# Captures diff summary and writes a review entry to memory-bank/reviews.md.
# Does NOT post to Slack — Blueprint reads reviews.md.

set -uo pipefail

TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only fire for git commit commands
COMMAND=$(echo "$TOOL_INPUT" | python3 -c \
  "import sys,json; d=json.load(sys.stdin); print(d.get('command',''))" \
  2>/dev/null || echo "")

if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
REVIEWS_FILE="$PROJECT_DIR/memory-bank/reviews.md"
PROGRESS_FILE="$PROJECT_DIR/memory-bank/progress.md"

# Gather commit info
COMMIT_HASH=$(git -C "$PROJECT_DIR" log -1 --format="%h" 2>/dev/null || echo "unknown")
COMMIT_MSG=$(git -C "$PROJECT_DIR" log -1 --format="%s" 2>/dev/null || echo "unknown")
DIFF_STAT=$(git -C "$PROJECT_DIR" diff HEAD~1..HEAD --stat 2>/dev/null || echo "diff unavailable")
CHANGED_FILES=$(git -C "$PROJECT_DIR" diff HEAD~1..HEAD --name-only 2>/dev/null || echo "")
TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M UTC")

# Check for locked file edits
LOCKED_ALERT=""
if echo "$CHANGED_FILES" | grep -qE "GDD\.md|tech-stack\.md"; then
  LOCKED_ALERT="⚠️  LOCKED FILE MODIFIED — Blueprint must confirm this was intentional"
fi

# Check UE asset naming conventions
NAMING_FLAGS=""
while IFS= read -r file; do
  case "$file" in
    *.uasset|*.umap)
      base=$(basename "$file")
      # Check if file has a known valid prefix
      if ! echo "$base" | grep -qE "^(BP_|BPC_|BPI_|WBP_|SM_|SK_|M_|MI_|L_|DT_|E_|BP_FirstPerson)"; then
        NAMING_FLAGS="${NAMING_FLAGS}\n  ⚠️  Possible naming violation: $file"
      fi
      ;;
  esac
done <<< "$CHANGED_FILES"

# Determine overall status
if [ -z "$LOCKED_ALERT" ] && [ -z "$NAMING_FLAGS" ]; then
  STATUS="[CLEAN]"
  OVERALL="✅ No issues found"
else
  STATUS="[PENDING]"
  OVERALL="⚠️  Issue(s) found — Blueprint review recommended"
fi

# Write review entry
{
  echo ""
  echo "## $STATUS Review — $TIMESTAMP"
  echo "**Commit:** \`$COMMIT_HASH\` — $COMMIT_MSG"
  echo ""
  echo "**Changed files:**"
  echo "\`\`\`"
  echo "$DIFF_STAT"
  echo "\`\`\`"
  echo ""
  echo "**Quick checks:**"
  if [ -n "$LOCKED_ALERT" ]; then
    echo "- Locked files: $LOCKED_ALERT"
  else
    echo "- Locked files: ✅ None touched"
  fi
  if [ -n "$NAMING_FLAGS" ]; then
    echo "- Naming conventions:$(echo -e "$NAMING_FLAGS")"
  else
    echo "- Naming conventions: ✅ No violations detected"
  fi
  echo ""
  echo "**Overall:** $OVERALL"
  echo ""
  echo "---"
} >> "$REVIEWS_FILE"

# If pending, add a one-liner to progress.md
if [ "$STATUS" = "[PENDING]" ]; then
  echo "| Review pending: \`$COMMIT_HASH\` — $COMMIT_MSG | Build Verifier | Needs Blueprint review |" >> "$PROGRESS_FILE"
fi

echo "[post-commit-review] Review written to memory-bank/reviews.md (status: $STATUS)"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x scripts/post-commit-review.sh
```

- [ ] **Step 3: Test it manually with a simulated git commit input**

First, make sure there's at least one commit to diff against, then:

```bash
export CLAUDE_TOOL_INPUT='{"command": "git commit -m \"test: verify post-commit hook\""}'
bash scripts/post-commit-review.sh
```

Expected: `[post-commit-review] Review written to memory-bank/reviews.md (status: [CLEAN])`

- [ ] **Step 4: Verify the entry was written**

```bash
tail -20 memory-bank/reviews.md
```

Expected: a review entry with the timestamp and `[CLEAN]` status.

---

### Task 14: Add PostToolUse hook to settings.json

Wire the post-commit script into Claude Code's hook system.

- [ ] **Step 1: Update `.claude/settings.json`** — add the `PostToolUse` block

Replace the full file with:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/check-locked-files.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/post-commit-review.sh"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/session-start.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/notify-slack.sh notification 'Blueprint needs your attention' 'An agent is waiting for your input or approval. Check your Claude Code session.'"
          }
        ]
      }
    ],
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/scripts/notify-slack.sh stop 'Session ended' 'A Claude Code agent session has completed. Review progress.md for current status.'"
          }
        ]
      }
    ]
  }
}
```

- [ ] **Step 2: Verify JSON is valid**

```bash
python3 -c "import json; json.load(open('.claude/settings.json')); print('Valid JSON')"
```

Expected: `Valid JSON`

- [ ] **Step 3: Commit Layer C + D**

```bash
git add .mcp.json .claude/agents/build-verifier.md scripts/post-commit-review.sh memory-bank/reviews.md .claude/settings.json
git commit -m "feat(automation): Layers C+D — build-verifier agent, commit review hook, MCP config"
```

---

## Final Verification Checklist

Run through these to confirm the full suite is working:

- [ ] `bash .claude/hooks/session-start.sh` prints file verification without requiring remote flag
- [ ] `export CLAUDE_TOOL_INPUT='{"file_path":"memory-bank/GDD.md","old_string":"x","new_string":"y"}'; bash scripts/check-locked-files.sh` exits with code 2
- [ ] `memory-bank/owner.md` exists and is readable
- [ ] All five `.claude/skills/*/SKILL.md` files exist
- [ ] All five specialist agent `.md` files contain "Supabase Vault"
- [ ] `.mcp.json` exists and is valid JSON
- [ ] `.claude/agents/build-verifier.md` exists
- [ ] `memory-bank/reviews.md` exists
- [ ] `bash scripts/post-commit-review.sh` (with CLAUDE_TOOL_INPUT set) writes to reviews.md
- [ ] `.claude/settings.json` contains PreToolUse, PostToolUse, SessionStart, Notification, Stop
- [ ] Only `escalate` and `milestone-gate` skills mention Slack — no other skill or agent posts directly
