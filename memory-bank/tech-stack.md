# Technical Architecture — CLAAAUDE STUDIO
## Status: Foundational decisions locked. Implementation decisions documented as made.

---

## Core Stack

| Layer | Decision | Rationale |
|-------|----------|-----------|
| Engine | Unreal Engine 5 | Industry standard, Lumen/Nanite for visual fidelity, Blueprint for rapid prototyping |
| Platform | Windows PC | Largest accessible PC gaming market, simplest distribution path for v1 |
| Distribution | Standalone .exe | No storefront dependency for v1. Steam/itch.io in v2. |
| Language | Blueprints (primary) + C++ (performance-critical) | Blueprint speeds iteration; C++ for anything hitting frame budget |
| Version control | Git + GitHub | Standard, free, integrates with CI tools |

---

## Unreal Engine 5 — Key Systems in Use

**Lumen** — Dynamic global illumination
- Used for: Hub lighting atmosphere, dungeon tension lighting
- Consideration: Performance cost. Monitor on minimum spec target hardware.

**Nanite** — Virtualized geometry
- Used for: Hub environmental detail
- Consideration: Not suitable for all asset types. Skeletal meshes excluded.

**Enhanced Input System** — Input handling
- Used for: FPS controls, UI navigation
- Note: Legacy input system deprecated. Enhanced Input only.

---

## Target Hardware Spec (Minimum)

**Status: LOCKED — M0**

| Component | Minimum |
|-----------|---------|
| GPU | NVIDIA GTX 1660 / AMD RX 5600 XT |
| CPU | Intel i5-8400 / AMD Ryzen 5 3600 |
| RAM | 16GB |
| Storage | SSD recommended, 20GB free |
| OS | Windows 10 64-bit |
| DirectX | 12 (Shader Model 6 — already configured in engine) |

---

## Asset Naming Conventions

**Status: LOCKED — M0**
Apply to all new ManyMoons-specific assets. Existing template assets (BP_FirstPersonCharacter, etc.) are exempt — do not rename assets that may break existing Blueprint references.

| Asset Type | Prefix | Example |
|-----------|--------|---------|
| Static Mesh | SM_ | SM_WallSection_01 |
| Skeletal Mesh | SK_ | SK_NPCVendor |
| Blueprint Actor | BP_ | BP_NPCBase |
| Blueprint Component | BPC_ | BPC_ReputationTracker |
| Blueprint Interface | BPI_ | BPI_Interactable |
| Material | M_ | M_WallConcrete |
| Material Instance | MI_ | MI_WallConcrete_Worn |
| Texture (diffuse) | T_Name_D | T_WallConcrete_D |
| Texture (normal) | T_Name_N | T_WallConcrete_N |
| Texture (roughness/metallic) | T_Name_R | T_WallConcrete_R |
| Map/Level | L_ | L_Hub_MainStreet |
| Widget Blueprint | WBP_ | WBP_HUD |
| Animation Blueprint | ABP_ | ABP_NPC_Idle |
| Animation Sequence | A_Char_Action | A_Player_Jump |
| Data Table | DT_ | DT_NPCDialogue |
| Enum | E_ | EFaction, EReputationTier |

---

## Architecture Decisions (ADR Log)

### ADR-001: Single-player only (v1)
**Decision:** No networking code in v1.
**Rationale:** Multiplayer adds 40%+ scope. Social features delivered through NPC depth, not player-to-player interaction.
**Review date:** M3 complete.

### ADR-002: Hand-crafted dungeons (v1)
**Decision:** No procedural generation in v1.
**Rationale:** Procedural generation requires significant additional systems. Hand-crafted ensures quality control and predictable boss encounter delivery.
**Review date:** Post-launch.

### ADR-003: Text dialogue (v1)
**Decision:** No voice acting in v1.
**Rationale:** Voice recording, casting, and implementation adds cost and time that would delay core systems.
**Review date:** Post-launch funding assessment.

### ADR-004: Blueprint-first development
**Decision:** Build in Blueprints, migrate to C++ only when performance requires.
**Rationale:** Blueprint iteration speed is faster during early milestones. Premature C++ optimization is a scope risk.
**Review date:** M1 complete.

### ADR-005: Save System — USaveGame
**Decision:** Use Unreal Engine's built-in `USaveGame` class.
**Rationale:** No external dependencies. Handles all v1 state (reputation tracks per faction, inventory contents, player last position in hub). Trivially extensible at M2 when save slots and more complex state are needed. Avoids reinventing serialization infrastructure.
**Review date:** M2 implementation.

### ADR-006: Blueprint Communication Pattern
**Decision:** Blueprint Interfaces (BPI) as the primary inter-actor communication pattern. Event Dispatchers reserved for one-to-many UI/HUD broadcasts.
**Rationale:** Interfaces allow loose coupling — any actor implementing `BPI_Interactable` can be called by the player without the player holding a typed reference. This is essential for the hub's varied interactive objects (NPCs, doors, faction boards). Event Dispatchers are appropriate for reputation-change-to-HUD or inventory-update-to-HUD patterns where a single source notifies many listeners. Note: this pattern is already partially validated — `BPI_TouchInterface` exists in the template confirming the engine and team lean toward interfaces.
**Review date:** M1 complete.
