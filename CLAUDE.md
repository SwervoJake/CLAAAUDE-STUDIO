# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Every agent reads this before doing anything else.

---

## Project Overview

An Oasis/SAO-inspired social-first futuristic town hub with dungeon side activity — single-player, Windows PC, downloadable .exe, built in Unreal Engine 5.

**The core loop:** Hub → Accept Contract → Dungeon → Loot → Upgrade → Return to Hub

Key locations:

- `ManyMoons/` — UE5 project root (`.uproject`, `Content/`, `Config/`)
- `ManyMoons/Content/` — all game assets (Blueprints, maps, meshes, animations)
- `ManyMoons/Config/` — engine and input configuration (`.ini` files)
- `memory-bank/` — agent briefing room, read before every task
- `docs/BUILD.md` — full build pipeline documentation
- `.claude/agents/` — per-agent instruction files (blueprint, orchestrator, systems, world, npc-narrative, combat, polish-qa)

UE5 binary assets (`.uasset`, `.umap`) are tracked via Git LFS. Always run `git lfs pull` after cloning.

---

## Build & Development Commands

### Prerequisites
- Unreal Engine 5.7 (must match `.uproject` `EngineAssociation`)
- Git LFS 3.x+
- Visual Studio 2022 with "Desktop development with C++" workload

### Clone
```bash
git clone https://github.com/SwervoJake/CLAAAUDE-STUDIO.git
cd CLAAAUDE-STUDIO
git lfs pull   # REQUIRED — skipping this breaks the project on open
```

### Open the Project
1. Double-click `ManyMoons/ManyMoons.uproject`
2. If prompted to rebuild modules, click **Yes**
3. First open compiles shaders — allow 5–15 minutes

### Play In Editor (PIE) Smoke Test
1. Open `Content/FirstPerson/Lvl_FirstPerson` in Content Browser
2. Press **Play** (`Alt+P`)
3. Verify: player moves, interactions fire on `BP_DoorFrame`/`BP_JumpPad`, no Blueprint compile errors in Output Log

### Package Windows Build
In editor: **Platforms → Windows → Package Project**

Command-line equivalent:
```bash
"C:\Program Files\Epic Games\UE_5.7\Engine\Build\BatchFiles\RunUAT.bat" ^
  BuildCookRun ^
  -project="C:\path\to\CLAAAUDE-STUDIO\ManyMoons\ManyMoons.uproject" ^
  -noP4 -platform=Win64 -clientconfig=Shipping ^
  -cook -allmaps -build -stage -pak -archive ^
  -archivedirectory="C:\Builds\ManyMoons"
```

Output: `WindowsNoEditor/ManyMoons.exe`

See `docs/BUILD.md` for the full smoke test checklist and troubleshooting guide.

---

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable, gate-passed builds only. Human approval required to merge. |
| `claude/*` | Active agent development branches |
| Feature branches | Per-agent work, merged to dev after review |

Never push directly to `main`. Milestone gates require human approval.

---

## Workflow

Use `TodoWrite` to break down complex tasks into tracked steps before starting implementation. Prefer planning mode for multi-part work.

Standard session flow:

1. Read `memory-bank/progress.md` and `memory-bank/tech-stack.md`
2. Create a todo list for the session's tasks
3. Work one task at a time, marking complete immediately on finish
4. Commit at natural milestones, not at the end of the session
5. Update `memory-bank/progress.md` before the session ends

---

## Non-Negotiables (Never Override These)

1. **Engine is Unreal Engine 5.** Do not propose alternatives.
2. **Platform is Windows PC.** No mobile, no console, no browser — v1 only.
3. **Scope is locked.** Do not add features outside the v1 definition without explicit human approval.
4. **Build must be stable.** Stability is a first-class requirement.
5. **Read memory-bank/ before starting any task.** Never make decisions that contradict the GDD.

---

## The v1 Definition of Done

- [ ] Windows .exe runs reliably without crashes
- [ ] Title screen, settings, new game, load game, pause, quit all function
- [ ] Full loop is playable: Hub → Contract → Dungeon → Loot → Upgrade → Hub
- [ ] 15–30 minutes of meaningful play
- [ ] 1 boss fight exists and functions
- [ ] No critical crashes in smoke test

---

## Technical Architecture (Key Decisions)

Full ADR log in `memory-bank/tech-stack.md`. Locked decisions:

- **Language:** Blueprints primary, C++ only when performance requires (ADR-004)
- **Input:** Enhanced Input System only — legacy input deprecated
- **Rendering:** Lumen (GI) + Nanite (geometry) + Virtual Shadow Maps + D3D12/SM6
- **Save system:** `USaveGame` built-in class (ADR-005)
- **Inter-actor communication:** Blueprint Interfaces (`BPI_`) for loose coupling; Event Dispatchers for one-to-many UI/HUD broadcasts (ADR-006)
- **Dungeons:** Hand-crafted only — no procedural generation v1 (ADR-002)
- **Networking:** None — single-player only v1 (ADR-001)

### Asset Naming Conventions (LOCKED)

| Asset Type | Prefix | Example |
|-----------|--------|---------|
| Blueprint Actor | `BP_` | `BP_NPCBase` |
| Blueprint Component | `BPC_` | `BPC_ReputationTracker` |
| Blueprint Interface | `BPI_` | `BPI_Interactable` |
| Widget Blueprint | `WBP_` | `WBP_HUD` |
| Static Mesh | `SM_` | `SM_WallSection_01` |
| Skeletal Mesh | `SK_` | `SK_NPCVendor` |
| Material | `M_` | `M_WallConcrete` |
| Material Instance | `MI_` | `MI_WallConcrete_Worn` |
| Map/Level | `L_` | `L_Hub_MainStreet` |
| Data Table | `DT_` | `DT_NPCDialogue` |
| Enum | `E_` | `EFaction`, `EReputationTier` |

Existing template assets (`BP_FirstPersonCharacter`, etc.) are exempt — do not rename them.

---

## The Three Factions

| Faction | Identity | Offers | Motto |
|---------|----------|--------|-------|
| 🏛️ Architects | Built the city. Cold, controlling. | Best tech upgrades | "We built this. We decide what it becomes." |
| ⚡ Vanguard | Ex-peacekeepers. Disciplined. | Combat gear, contracts | "Order doesn't maintain itself." |
| 🌿 The Hollow | The forgotten. Warm but guarded. | Best prices, hidden quests | "We don't own the city. We live in it." |

**Reputation system:** Neutral (0) → Trusted (50) → Allied (100). No hard locks — all three achievable in v1. Full lore in `memory-bank/factions.md`.

---

## Milestone Definitions

| Milestone | Name | Done When |
|-----------|------|-----------|
| M0 | Foundation | Repeatable build pipeline works. Tiny end-to-end feature ships. |
| M1 | Social Hub First Playable | Main street + 3 interiors, 5 NPCs, reputation system, stable FPS controller, Windows build. |
| M2 | Vertical Slice | Dungeon (8–12 rooms, 2 enemy types, 1 boss), loot/inventory, save/load, reputation affects gameplay. |
| M3 | Launch v1 | Onboarding, settings, bug triage, balance pass complete. |

**Current status:** M0 — In Progress. See `memory-bank/progress.md`.

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

Each agent has a single domain. Do not cross domain boundaries without flagging it. Agent-specific instructions are in `.claude/agents/<agent-name>.md`.

---

## How Agents Must Behave

1. **Read before write.** Check `memory-bank/` before making any decision.
2. **Scope discipline.** If a feature is not in the GDD, do not build it. Flag it instead.
3. **Stability first.** Never sacrifice a stable build for a feature.
4. **Document decisions.** Any significant technical decision goes in `memory-bank/tech-stack.md`.
5. **Flag blockers immediately.** Do not work around a blocker silently. Surface it.
6. **One milestone at a time.** Do not start M2 work while M1 is incomplete.

---

## Integration & DevOps

- **Slack** — `#claaaude-studio` (C0AKGFLLJ6A) via Slack MCP. Blueprint sends escalations, milestone gates, and ADR locks here.
- **Session hooks** — `.claude/settings.json` defines `SessionStart`, `Notification`, and `Stop` hooks. `scripts/notify-slack.sh` handles webhook-based notifications.
- **Vault v.1 (Supabase)** — `wofvwgvaoqwcfgleirne` (`us-west-2`). Research knowledge base. Orchestrator queries `research_entries` to inject domain context into task prompts before dispatch.

When setting up integrations, verify the connection works by sending a test message before marking the task complete.

---

## File Reference

| File | Purpose |
|------|---------|
| `memory-bank/GDD.md` | Full game design document (LOCKED v1.0) |
| `memory-bank/factions.md` | Faction lore, mechanics, relationships |
| `memory-bank/tech-stack.md` | Architecture decisions and ADR log |
| `memory-bank/milestones.md` | Milestone definitions and acceptance criteria |
| `memory-bank/progress.md` | Current status — update before session ends |
| `docs/BUILD.md` | Full build pipeline and smoke test checklist |
