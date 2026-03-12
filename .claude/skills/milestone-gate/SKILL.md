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
