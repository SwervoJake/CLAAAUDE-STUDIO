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
