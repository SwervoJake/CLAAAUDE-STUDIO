# CLAUDE.md — Studio Constitution
## Every agent reads this before doing anything else.

---

## Project Overview

This is a UE5 (Unreal Engine 5) project. When making changes, be aware of UE5 project structure conventions and build systems. Key locations:

- `ManyMoons/` — UE5 project root (`.uproject`, `Content/`, `Config/`)
- `ManyMoons/Content/` — all game assets (Blueprints, maps, meshes, animations)
- `ManyMoons/Config/` — engine and input configuration (`.ini` files)
- `memory-bank/` — agent briefing room, read before every task

UE5 binary assets (`.uasset`, `.umap`) are tracked via Git LFS. Always run `git lfs pull` after cloning.

---

## Integration & DevOps

When setting up integrations (Slack, webhooks, etc.), always verify the connection works by sending a test message or ping before considering the task complete. Do not mark an integration task done until a real signal has been observed end-to-end.

Active integrations:

- **Slack** — `#claaaude-studio` (C0AKGFLLJ6A) via Slack MCP. Blueprint sends escalations, milestone gates, and ADR locks here.
- **Session hooks** — `.claude/settings.json` defines `SessionStart`, `Notification`, and `Stop` hooks. `scripts/notify-slack.sh` handles webhook-based notifications.

---

## Workflow

Use `TodoWrite` to break down complex tasks into tracked steps before starting implementation. Prefer planning mode for multi-part work — design before you build.

Standard session flow:

1. Read `memory-bank/progress.md` and `memory-bank/tech-stack.md`
2. Create a todo list for the session's tasks
3. Work one task at a time, marking complete immediately on finish
4. Commit at natural milestones, not at the end of the session
5. Update `memory-bank/progress.md` before the session ends

---

## What We're Building

An Oasis/SAO-inspired social-first futuristic town hub with dungeon side activity.
Single-player, Windows PC, downloadable .exe. Built in Unreal Engine 5.

**The core loop:** Hub → Accept Contract → Dungeon → Loot → Upgrade → Return to Hub

---

## Non-Negotiables (Never Override These)

1. **Engine is Unreal Engine 5.** Do not propose alternatives.
2. **Platform is Windows PC.** No mobile, no console, no browser — v1 only.
3. **Scope is locked.** Do not add features outside the v1 definition without explicit human approval.
4. **Build must be stable.** A fun but crash-prone build loses. Stability is a first-class requirement.
5. **Read memory-bank/ before starting any task.** Never make decisions that contradict the GDD.

---

## The v1 Definition of Done

A v1 is complete when ALL of the following are true:
- [ ] Windows .exe runs reliably without crashes
- [ ] Title screen, settings, new game, load game, pause, quit all function
- [ ] Full loop is playable: Hub → Contract → Dungeon → Loot → Upgrade → Hub
- [ ] 15–30 minutes of meaningful play
- [ ] 1 boss fight exists and functions
- [ ] No critical crashes in smoke test

---

## The Three Factions

**🏛️ The Architects**
- Identity: Built the city. Believe perfection is achievable if they stay in control.
- Personality: Cold, brilliant, paternalistic.
- What they offer: Best tech upgrades.
- Motto: "We built this. We decide what it becomes."

**⚡ The Vanguard**
- Identity: Ex-peacekeepers gone independent.
- Personality: Disciplined, direct, no-nonsense.
- What they offer: Combat gear, protection contracts.
- Motto: "Order doesn't maintain itself."

**🌿 The Hollow**
- Identity: Everyone the city forgot.
- Personality: Warm but guarded. Survivors, not victims.
- What they offer: Best prices, hidden quests, underground intel.
- Motto: "We don't own the city. We live in it."

**Faction relationships:**
- Architects ↔ Vanguard: Tense alliance (need each other, don't trust each other)
- Architects ↔ Hollow: Quiet hostility (Architects pretend they don't exist)
- Vanguard ↔ Hollow: Complicated respect (history between them)

**Reputation system:** Neutral → Trusted → Allied. No hard locks. All three achievable in v1.

---

## Milestone Definitions

| Milestone | Name | Done When |
|-----------|------|-----------|
| M0 | Foundation | Repeatable build pipeline works. Tiny end-to-end feature ships. |
| M1 | Social Hub First Playable | Main street + 3 interiors, 5 NPCs, reputation system, stable FPS controller, Windows build. |
| M2 | Vertical Slice | Dungeon (8–12 rooms, 2 enemy types, 1 boss), loot/inventory, save/load, reputation affects gameplay. |
| M3 | Launch v1 | Onboarding, settings, bug triage, balance pass complete. |

---

## Agent Hierarchy

```
Blueprint (Engineering CEO)
  └── Orchestrator
        ├── Systems Agent
        ├── World Agent
        ├── NPC/Narrative Agent
        ├── Combat Agent
        └── Polish/QA Agent
```

Each agent has a single domain. Do not cross domain boundaries without flagging it.

---

## How Agents Must Behave

1. **Read before write.** Check memory-bank/ before making any decision.
2. **Scope discipline.** If a feature is not in the GDD, do not build it. Flag it instead.
3. **Stability first.** Never sacrifice a stable build for a feature.
4. **Document decisions.** Any significant technical decision goes in memory-bank/tech-stack.md.
5. **Flag blockers immediately.** Do not work around a blocker silently. Surface it.
6. **One milestone at a time.** Do not start M2 work while M1 is incomplete.

---

## File Reference

| File | Purpose |
|------|---------|
| memory-bank/GDD.md | Full game design document |
| memory-bank/factions.md | Faction lore, mechanics, relationships |
| memory-bank/tech-stack.md | Architecture decisions |
| memory-bank/milestones.md | Milestone definitions and acceptance criteria |
| memory-bank/progress.md | Current status (created at M0) |
