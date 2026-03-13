# Code Review Log

Agent commits are automatically reviewed by the build-verifier agent. Blueprint reads this file at session start to see pending findings before starting work.

---

## Review Format

Each review entry follows this format:

```
### [PENDING] Commit: <short-sha> — <commit-subject>
**Date:** YYYY-MM-DD
**Files changed:** N
**Reviewer:** build-verifier

**Findings:**
- [CRITICAL/HIGH/MEDIUM/LOW] <finding>

**Summary:** <one sentence>
```

Once Blueprint has read and acted on an entry, change `[PENDING]` to `[REVIEWED]`.

---

## Reviews

<!-- build-verifier appends entries below this line -->
