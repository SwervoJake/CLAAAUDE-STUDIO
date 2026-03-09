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

---

## Target Hardware Spec (Minimum)

To be defined by Systems Agent at M0. Starting reference point:
- GPU: NVIDIA GTX 1660 / AMD RX 5600 XT
- RAM: 16GB
- Storage: 20GB (estimated)
- OS: Windows 10 64-bit

---

## Decisions Pending (M0 Tasks)

- [ ] Define minimum hardware spec formally
- [ ] Choose save system approach (Unreal SaveGame class vs custom)
- [ ] Define asset naming conventions
- [ ] Confirm Blueprint communication pattern (Event Dispatchers vs Interfaces)
