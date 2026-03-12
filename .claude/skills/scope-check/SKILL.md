---
name: scope-check
description: Verify whether a proposed feature or task is within the ManyMoons v1 GDD scope. All agents invoke this automatically before starting any new work that wasn't explicitly assigned by Orchestrator. Claude-only — not user-invocable.
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
