# CLAAAUDE STUDIO 🎮

An AI-powered AAA game studio building an Oasis/SAO-inspired game using competing agent teams.

## What We're Building

A social-first futuristic town hub with dungeon side activity — downloadable Windows .exe, single-player v1.

**Engine:** Unreal Engine 5
**Platform:** Windows PC
**v1 Scope:** Hub → Contract → Dungeon → Loot → Upgrade → Hub loop, 15–30 min playtime, 1 boss fight

## The Three Factions

| Faction | Role | Motto |
|---------|------|-------|
| 🏛️ The Architects | Built the city. Cold, brilliant, controlling. | "We built this. We decide what it becomes." |
| ⚡ The Vanguard | Ex-peacekeepers. Disciplined, direct. | "Order doesn't maintain itself." |
| 🌿 The Hollow | The forgotten. Warm but guarded. | "We don't own the city. We live in it." |

## Project Structure

```
memory-bank/       ← Agent briefing room (read this first)
  GDD.md           ← Master game design document
  factions.md      ← Architects, Vanguard, Hollow reference
  tech-stack.md    ← Architecture decisions
  milestones.md    ← M0–M3 acceptance criteria
.claude/
  agents/          ← Agent instruction files
CLAUDE.md          ← Rules every agent reads before starting
README.md          ← Project overview
```

## Milestones

- **M0** — Foundation: repeatable build pipeline, tiny end-to-end feature
- **M1** — Social Hub First Playable: main street, 3 interiors, 5 NPCs, reputation system
- **M2** — Vertical Slice: dungeon, loot/inventory, save/load, reputation affects gameplay
- **M3** — Launch v1: onboarding, settings, bug triage, balance pass

## Agent Competition

Two identical agent teams race to each milestone. Winner scored on: time, stability, fun, social depth, scope discipline.
