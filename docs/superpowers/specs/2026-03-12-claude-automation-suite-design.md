# Claude Automation Suite — Design Spec
**Date:** 2026-03-12
**Status:** Approved
**Author:** Blueprint (via brainstorming session with Jacob)

---

## Overview

A layered set of Claude Code automations that protect locked documents, give each agent consistent workflows, connect the Vault and Slack to the whole team, and automatically review every commit — all routed through Blueprint so Jacob only hears from one source.

**Delivery order:** A → B → D → C (each layer independently committable and testable)

---

## Layer A — Protective Hooks

### A1: Fix SessionStart Hook
**File:** `.claude/hooks/session-start.sh`

Remove the `CLAUDE_CODE_REMOTE` guard that causes the hook to silently exit in local sessions. After the fix, memory-bank file verification runs on every session — local or remote.

Add `memory-bank/owner.md` to the required-files checklist inside the hook so agents are warned if Jacob's context document is missing.

**Effect:** No session ever starts without verifying the memory-bank is intact and owner context exists.

---

### A2: GDD + ADR Lock Hook
**Files:** `.claude/settings.json`, `scripts/check-locked-files.sh`

A `PreToolUse` hook entry that intercepts every `Edit` and `Write` tool call. A companion shell script reads the file path from the tool input and exits with code 2 (blocking the call) if the path contains `GDD.md` or `tech-stack.md`.

Block message: `[BLOCKED] Locked file — Blueprint approval required before editing GDD.md or tech-stack.md`

**Effect:** Agents cannot accidentally modify locked documents mid-task. Blueprint must explicitly approve any change.

---

### A3: Owner Context Document
**File:** `memory-bank/owner.md`

A new document written by Jacob containing his mission, priorities, and anything he wants every agent to know about him and the project. Created as a starter template — Jacob fills it in.

Verified by the SessionStart hook and referenced in CLAUDE.md's read-before-write instructions.

**Effect:** Every agent reads Jacob's context at the start of every session without being told to.

---

## Layer B — Skills

All skills live in `.claude/skills/<name>/SKILL.md`.

### B1: `adr` — Document an Architecture Decision
**Owner:** Blueprint
**Invocation:** Both Blueprint and user

Reads `memory-bank/tech-stack.md` to find the next ADR number, then appends a correctly-formatted ADR block (decision / rationale / tradeoffs / review date). Blueprint invokes this whenever Rule 2 triggers (any hard-to-reverse or multi-agent decision).

**Effect:** ADR log stays consistent and never misses an entry.

---

### B2: `milestone-gate` — Run Acceptance Checklist
**Owner:** Blueprint
**Invocation:** User-only (has Slack side effect)

Reads the current milestone's checklist from `memory-bank/milestones.md`, walks Blueprint through each item (pass/fail), updates the checklist in `memory-bank/progress.md`, then posts the gate result to `#claaaude-studio` via Slack. The only skill with a direct Slack post.

**Effect:** Milestone gates are formal, documented, and Jacob is notified via the single Slack channel.

---

### B3: `escalate` — Send a Jacob Escalation
**Owner:** Blueprint
**Invocation:** User-only (has Slack side effect)

Formats and sends Blueprint's standard escalation block to `#claaaude-studio`:
```
ESCALATION TO JACOB
Decision needed: [one sentence]
Option A: [what + consequence]
Option B: [what + consequence]
My recommendation: [which + why]
What happens if we wait: [cost of delay]
```
The only other skill with a direct Slack post.

**Effect:** Jacob gets structured, actionable escalations — not raw agent output.

---

### B4: `progress-update` — Update the Progress Log
**Owner:** Orchestrator
**Invocation:** Both

Updates `memory-bank/progress.md` in the correct format: moves tasks between Active/Completed, updates the last-updated date, appends blockers. Orchestrator invokes this at the end of every work cycle.

**Effect:** `progress.md` stays accurate without Orchestrator having to re-read format instructions each time.

---

### B5: `scope-check` — Verify a Feature Is in v1 Scope
**Owner:** All agents
**Invocation:** Claude-only (internal gate)

Reads `memory-bank/GDD.md` and returns whether a proposed feature or task is within the v1 definition. If out of scope, returns the closest in-scope equivalent and logs the out-of-scope request.

**Effect:** Agents catch scope drift before writing a single line of Blueprint code.

---

### B6: Supabase Vault Access for Specialist Agents
**Files:** `.claude/agents/systems-agent.md`, `world-agent.md`, `npc-narrative-agent.md`, `combat-agent.md`, `polish-qa-agent.md`

Add a consistent instruction to each specialist agent file: *"Before starting any task, query the Supabase Vault (table: `research_entries`) for entries relevant to your domain. Use the results to inform your approach."*

The Supabase MCP (Layer D) makes this available project-wide — no per-agent setup needed.

**Effect:** Every specialist agent draws from the knowledge base before building, not just the Orchestrator.

---

## Layer D — MCP Connections

**File:** `.mcp.json` (repo root, committed)

```json
{
  "mcpServers": {
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase@latest", "--access-token", "${SUPABASE_ACCESS_TOKEN}"],
      "env": {
        "SUPABASE_PROJECT_ID": "wofvwgvaoqwcfgleirne"
      }
    },
    "slack": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
        "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
      }
    }
  }
}
```

Tokens stay out of the repo via environment variables. Since Jacob already has both MCPs running in Claude Desktop, the tokens are already configured — this file just makes the connections available inside Claude Code projects.

**Effect:** All agents (Blueprint, Orchestrator, all specialists) can query the Supabase Vault and read/write Slack natively. No manual API calls.

---

## Layer C — Build-Verifier Agent + Commit Review Hook

### Slack Rule (critical)
**Only Blueprint posts to Slack.** The build-verifier writes findings internally. Blueprint reads them and decides what reaches Jacob.

---

### C1: `build-verifier` Agent
**File:** `.claude/agents/build-verifier.md`
**Owner:** Polish/QA Agent

When invoked, the agent:
1. Reads `git diff HEAD~1..HEAD` and `git log -1`
2. Checks for: naming convention violations (BP_, SM_, WBP_, etc.), edits to locked files that bypassed the hook, features that appear out of v1 scope, and commit message quality
3. Writes a structured findings report to `memory-bank/reviews.md` with a timestamp and commit hash
4. If issues are found, appends a one-line summary to the "Pending Blueprint Review" section of `memory-bank/progress.md`

The agent does NOT post to Slack. Blueprint reads `reviews.md` and escalates to Jacob if warranted.

---

### C2: Commit Review Hook
**Files:** `.claude/settings.json`, `scripts/post-commit-review.sh`

A `PostToolUse` hook that fires when a Bash tool call contains `git commit`. The shell script:
1. Captures `git diff HEAD~1..HEAD --stat` and `git log -1 --oneline`
2. Runs a quick naming-convention grep on changed file names
3. Writes a timestamped entry to `memory-bank/reviews.md`
4. Appends a one-liner to `progress.md` flagging Blueprint to check reviews

Non-blocking — the commit lands regardless. Review arrives in `reviews.md` within seconds.

---

### C3: SessionStart Review Check (addition to A1)
The SessionStart hook gains one additional check: if `memory-bank/reviews.md` contains entries marked `[PENDING]`, it prints a warning at session start so Blueprint sees them immediately.

**Effect:** Blueprint is notified of pending reviews at the top of every session. Nothing gets lost between sessions.

---

## Chain of Command — Slack Flow

```
build-verifier → reviews.md → Blueprint reads → escalate skill → #claaaude-studio → Jacob
specialist agents → Orchestrator → Blueprint → escalate skill → #claaaude-studio → Jacob
milestone gates → Blueprint → milestone-gate skill → #claaaude-studio → Jacob
```

Only the `escalate` and `milestone-gate` skills post to Slack. Everything else routes through Blueprint first.

---

## Files Created / Modified

| File | Action | Layer |
|------|--------|-------|
| `.claude/hooks/session-start.sh` | Modified | A |
| `scripts/check-locked-files.sh` | Created | A |
| `.claude/settings.json` | Modified (PreToolUse + PostToolUse hooks) | A, C |
| `memory-bank/owner.md` | Created (template) | A |
| `.claude/skills/adr/SKILL.md` | Created | B |
| `.claude/skills/milestone-gate/SKILL.md` | Created | B |
| `.claude/skills/escalate/SKILL.md` | Created | B |
| `.claude/skills/progress-update/SKILL.md` | Created | B |
| `.claude/skills/scope-check/SKILL.md` | Created | B |
| `.claude/agents/systems-agent.md` | Modified (Supabase instruction) | B |
| `.claude/agents/world-agent.md` | Modified (Supabase instruction) | B |
| `.claude/agents/npc-narrative-agent.md` | Modified (Supabase instruction) | B |
| `.claude/agents/combat-agent.md` | Modified (Supabase instruction) | B |
| `.claude/agents/polish-qa-agent.md` | Modified (Supabase instruction) | B |
| `.mcp.json` | Created | D |
| `.claude/agents/build-verifier.md` | Created | C |
| `scripts/post-commit-review.sh` | Created | C |
| `memory-bank/reviews.md` | Created | C |

---

## Success Criteria

- [ ] Local session runs session-start hook and verifies all required files
- [ ] Attempting to edit `GDD.md` or `tech-stack.md` is blocked with a clear message
- [ ] `owner.md` exists and is verified on startup
- [ ] All 5 skills are invocable and produce correctly-formatted output
- [ ] All specialist agents query Supabase before starting tasks
- [ ] `.mcp.json` connects to Supabase and Slack in Claude Code
- [ ] Every `git commit` triggers a review entry in `memory-bank/reviews.md`
- [ ] Pending reviews are flagged to Blueprint at session start
- [ ] No agent other than Blueprint posts to `#claaaude-studio`
