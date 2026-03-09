# Milestone Definitions
## Status: LOCKED

---

## How Milestones Work

A milestone is complete only when ALL acceptance criteria are met — not "mostly met."
Agents do not begin the next milestone until the current one passes.
Human approval required to advance past each milestone gate.

---

## M0 — Foundation
**Theme:** Prove the pipeline works before building anything real.

**Acceptance criteria:**
- [ ] Unreal Engine 5 project created and committed to GitHub
- [ ] Project opens without errors on a clean clone
- [ ] Repeatable build process documented
- [ ] One tiny end-to-end feature ships: player can move through a room and trigger one event
- [ ] Asset naming conventions defined and documented in tech-stack.md
- [ ] Minimum hardware spec defined

---

## M1 — Social Hub First Playable
**Theme:** The hub IS the game. Prove it is worth being in.

**Acceptance criteria:**
- [ ] Main Street playable — player can walk the full length
- [ ] 3 faction interiors accessible (Architects HQ, Vanguard Post, Hollow Market)
- [ ] 5 NPCs with dialogue (reputation-gated lines functional)
- [ ] Reputation system functional — all 3 tracks increment correctly
- [ ] FPS controller stable — no physics bugs, no fall-through, smooth movement
- [ ] Windows .exe builds and runs on minimum spec hardware
- [ ] Stable 30fps minimum on minimum spec target

---

## M2 — Vertical Slice
**Theme:** The full loop, end to end.

**Acceptance criteria:**
- [ ] Dungeon accessible from hub via contract board
- [ ] Dungeon contains 8–12 rooms with at least 2 distinct room types
- [ ] 2 enemy types functional (AI, hitbox, loot drop)
- [ ] 1 boss fight functional (unique mechanics, not just a bigger enemy)
- [ ] Loot system functional — items collected, stored in inventory
- [ ] Upgrade system functional — at least 1 upgrade path per faction
- [ ] Save/load functional — game state persists between sessions
- [ ] Reputation affects at least 2 gameplay outcomes
- [ ] Full loop completable without developer intervention

---

## M3 — Launch v1
**Theme:** Something a stranger could download and enjoy.

**Acceptance criteria:**
- [ ] Onboarding complete — new player understands the game without instructions
- [ ] Settings menu functional (resolution, volume, keybinds)
- [ ] All critical crashes resolved (zero crashes in 30-minute smoke test)
- [ ] Balance pass complete
- [ ] .exe packages cleanly on clean Windows machine
- [ ] Human playtester completes full loop without external help

---

## Scoring (Agent Competition)

| Criterion | Weight |
|-----------|--------|
| Time to milestone completion | 25% |
| Build stability | 25% |
| Fun / vibe (human judgment) | 20% |
| Social depth (faction/NPC quality) | 15% |
| Scope discipline | 15% |
