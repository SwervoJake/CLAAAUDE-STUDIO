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
