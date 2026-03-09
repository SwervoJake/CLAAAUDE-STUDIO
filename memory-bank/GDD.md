# Game Design Document — CLAAAUDE STUDIO
## Version: 1.0 LOCKED
## Status: All v1 decisions finalized. Do not modify without human approval.

---

## One-Line Pitch

A social-first futuristic city hub where your reputation with three rival factions determines what is available to you — with dungeons as the side activity, not the main event.

---

## Inspiration

- **Oasis** (Ready Player One) — social-first virtual world, the hub IS the game
- **Sword Art Online** — high-stakes dungeon tension, gear progression, faction depth
- **Distinction:** Most games make the hub a loading screen. We make it the world.

---

## Platform & Scope

| Decision | Choice | Locked? |
|----------|--------|---------|
| Platform | Windows PC (.exe) | Yes |
| Engine | Unreal Engine 5 | Yes |
| Player count | Single-player v1 | Yes |
| Perspective | FPS | Yes |
| Multiplayer | Out of scope v1 | Yes |
| VR | Out of scope v1 | Yes |

---

## The Core Loop

```
Wake up in Hub
  → Talk to NPCs, check faction boards
    → Accept a Contract
      → Enter Dungeon
        → Fight enemies, find loot
          → Defeat boss (or retreat)
            → Return to Hub with loot
              → Upgrade gear / improve reputation
                → Unlock new hub areas and NPC interactions
                  → Repeat
```

**The key design principle:** The hub evolves as your reputation grows. New doors open. New NPCs appear. Faction members react differently to you. The dungeon funds your life in the city — it does not replace it.

---

## Hub Design

**Main Street** — The spine of the city. Always accessible.
- Faction storefronts visible (access depends on reputation)
- 5 NPCs with distinct personalities and dialogue trees
- Environmental storytelling: faction tension visible in how the street is organized

**Three Interiors (M1 target):**
1. Architects HQ — clean, white, efficient. Tech upgrades, cold welcome.
2. Vanguard Post — military aesthetic. Gear, contracts, respect earned not given.
3. The Hollow Market — hidden entrance, warm lighting, best deals for the trusted.

---

## NPC Design (v1 — 5 NPCs)

Each NPC has:
- Faction affiliation (or neutral)
- Reputation threshold for full dialogue access
- One piece of world lore they will share when trusted
- A unique role in the hub economy

NPC names and full dialogue to be written by NPC/Narrative Agent.

---

## Reputation System

**Three tracks — one per faction:**
```
Neutral (0) → Trusted (50) → Allied (100)
```

**How reputation is earned:**
- Completing faction contracts
- Bringing faction-relevant loot back from dungeons
- Dialogue choices with NPCs
- (Allied) Completing hidden quests unlocked at Trusted

**What reputation unlocks:**
- Neutral: Basic storefront access, surface dialogue
- Trusted: Discounts, extended dialogue, faction side quests
- Allied: Hidden areas, best gear, faction lore reveals, unique NPC interactions

**Design rule:** No hard faction locks. A player can Allied with all three in v1. Tension is narrative, not mechanical gate-keeping.

---

## Dungeon Design

**v1 Spec:**
- 8–12 rooms per dungeon run
- 2 enemy types
- 1 boss fight (end of dungeon)
- Loot drops tied to faction utility (Architects want tech, Vanguard wants weapons, Hollow wants rare goods)
- Retreat is always an option — no permadeath v1

**Room types:**
- Combat rooms
- Loot rooms
- Environmental hazard rooms
- Boss room (final)

---

## Loot & Progression

**Loot categories:**
- Gear (combat upgrades — presented to Vanguard)
- Tech components (presented to Architects)
- Rare goods (presented to Hollow)

**Upgrade system:**
- Each faction upgrades items in their specialty domain
- Upgraded gear affects combat effectiveness and dialogue options

---

## Tone & Aesthetic

**Tone:** Grounded sci-fi. The city feels real, lived-in, politically tense. Not utopia. Not dystopia. A city with factions doing what factions do.

**Visual direction:**
- Clean futurism with wear and tear
- Architects zone: white, geometric, oppressively perfect
- Vanguard zone: industrial, organized, scarred from past conflicts
- Hollow zone: warm light, hidden paths, things repurposed from what others threw away

**Audio direction:**
- Hub: ambient city sounds, faction-specific music zones
- Dungeon: tense, minimal, punctuated by combat cues

---

## Out of Scope (v1)

- Multiplayer of any kind
- VR support
- Voice acting (text dialogue v1)
- Crafting system beyond basic upgrades
- Open world (hub + dungeon only)
- Procedural dungeon generation (hand-crafted v1)
- More than 3 factions
- More than 1 dungeon type
