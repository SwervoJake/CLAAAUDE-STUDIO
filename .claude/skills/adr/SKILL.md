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
