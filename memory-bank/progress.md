# Studio Progress Log
Last updated: 2026-03-09
Current milestone: M0 — In Progress

## Active Tasks
| Task | Agent | Status | Blocker |
|------|-------|--------|---------|
| Verify clean clone + PIE smoke test | Systems Agent | Not started | Requires UE5 editor open |
| Verify packaged .exe smoke test | Systems Agent | Not started | Requires UE5 editor open |
| Human M0 gate review | Blueprint | Not started | Awaiting smoke test results |

## Completed This Milestone
| Task | Agent | Completed |
|------|-------|-----------|
| Initialize UE5 project (ManyMoons, FP template, v5.7) | Systems Agent | Pre-session |
| Set up Enhanced Input System (IA_Move, IA_Look, IMC_Default) | Systems Agent | Pre-session |
| Create playable test level (Lvl_FirstPerson, 61 actors) | Systems Agent | Pre-session |
| Add interactables: BP_DoorFrame, BP_JumpPad, BP_WobbleTarget | Systems Agent | Pre-session |
| Configure Lumen, Nanite, Virtual Shadow Maps, D3D12/SM6 | Systems Agent | Pre-session |
| Enable GameplayStateTree plugin | Systems Agent | Pre-session |
| Add .gitignore for UE5 | Systems Agent | Pre-session |
| Create .gitattributes with Git LFS for binary assets | Blueprint | 2026-03-09 |
| Fix project name in DefaultGame.ini (→ ManyMoons) | Blueprint | 2026-03-09 |
| Document minimum hardware spec (ADR, locked) | Blueprint | 2026-03-09 |
| Document save system decision: USaveGame (ADR-005) | Blueprint | 2026-03-09 |
| Document Blueprint communication pattern: BPI (ADR-006) | Blueprint | 2026-03-09 |
| Define asset naming conventions in tech-stack.md | Blueprint | 2026-03-09 |
| Create docs/BUILD.md with build pipeline documentation | Blueprint | 2026-03-09 |

## Backlog (out of scope for current milestone)
- Hub level gray-box (L_Hub_MainStreet) — M1
- BP_ReputationManager — M1
- BP_NPC_Base — M1
- Faction interiors (3x) — M1
- Full NPC dialogue trees — M1
- Dungeon — M2

## Design Decisions
See memory-bank/tech-stack.md for full ADR log (ADR-001 through ADR-006 locked).

## Milestone Acceptance Checklist — M0
- [x] Unreal Engine 5 project created and committed to GitHub
- [ ] Project opens without errors on a clean clone *(requires PIE verification)*
- [x] Repeatable build process documented (docs/BUILD.md)
- [ ] Player can move through a room and trigger one interaction event *(requires PIE verification)*
- [x] Asset naming conventions defined in memory-bank/tech-stack.md
- [x] Minimum hardware spec defined

## Notes
Session zero documentation complete. Pre-session work (UE5 project, FPS template, test level, interactables) was already done before this session.
M0 documentation sprint complete 2026-03-09. Remaining gate items require UE5 editor open for PIE/packaging verification.
Human gate review required to advance to M1.
