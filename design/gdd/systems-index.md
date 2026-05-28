# Systems Index: Hearth & Horn

> **Status**: Approved
> **Created**: May 28, 2026
> **Last Updated**: May 28, 2026
> **Source Concept**: design/gdd/game-concept.md

---

## Overview

Hearth & Horn is a cozy, grid-based travel and camping adventure. To support this vision, the systems structure must prioritize character caretaking, simple turn-based stance combat, and mobile camp management. The technical design is kept clean and lightweight, leveraging Godot 4.6's 2D engine and static GDScript to export easily to web browsers for child-friendly accessibility.

---

## Systems Enumeration

| # | System Name | Category | Priority | Status | Design Doc | Depends On |
|---|-------------|----------|----------|--------|------------|------------|
| 1 | `MonsterData` | Gameplay | MVP | Designed | [monster-data.md](file:///Users/cation/Game-Studios/design/gdd/monster-data.md) | None |
| 2 | `InventorySystem` | Economy | MVP | Designed | [inventory-system.md](file:///Users/cation/Game-Studios/design/gdd/inventory-system.md) | None |
| 3 | `GridMovement` | Core | MVP | Designed | [grid-movement.md](file:///Users/cation/Game-Studios/design/gdd/grid-movement.md) | `SaveManager` (Optional for MVP) |
| 4 | `BattleEngine` | Gameplay | MVP | Designed | [battle-engine.md](file:///Users/cation/Game-Studios/design/gdd/battle-engine.md) | `MonsterData` |
| 5 | `CampManager` | Gameplay | MVP | Designed | [camp-manager.md](file:///Users/cation/Game-Studios/design/gdd/camp-manager.md) | `InventorySystem`, `RecipeDatabase` (Placeholder) |
| 6 | `BattleUI` | UI | MVP | Designed | [battle-ui.md](file:///Users/cation/Game-Studios/design/gdd/battle-ui.md) | `BattleEngine` |
| 7 | `SaveManager` (inferred) | Persistence | Vertical Slice | Not Started | — | None |
| 8 | `BondManager` (inferred) | Gameplay | Vertical Slice | Not Started | — | `MonsterData`, `SaveManager` |
| 9 | `RecipeDatabase` (inferred) | Economy | Vertical Slice | Not Started | — | `InventorySystem`, `SaveManager` |
| 10 | `WildAI` (inferred) | Gameplay | Vertical Slice | Not Started | — | `BattleEngine` |
| 11 | `CampUI` (inferred) | UI | Vertical Slice | Not Started | — | `CampManager` |
| 12 | `TalentTree` | Progression | Alpha | Not Started | — | `BondManager`, `SaveManager` |
| 13 | `FieldHazards` (inferred) | Gameplay | Alpha | Not Started | — | `GridMovement`, `TalentTree`, `MonsterData` |

---

## Categories

| Category | Description | Typical Systems |
|----------|-------------|-----------------|
| **Core** | Foundations everything depends on | GridMovement |
| **Gameplay** | The systems that make the game fun | BattleEngine, CampManager, BondManager, WildAI, FieldHazards |
| **Progression** | How the player grows over time | TalentTree |
| **Economy** | Resource collection and consumption | InventorySystem, RecipeDatabase |
| **Persistence** | Save state and continuity | SaveManager |
| **UI** | Player-facing screens and HUD | BattleUI, CampUI |

---

## Priority Tiers

| Tier | Definition | Target Milestone | Design Urgency |
|------|------------|------------------|----------------|
| **MVP** | Required for the core loop to function. Test "is this fun?" | Web-playable prototype | Design FIRST |
| **Vertical Slice** | Adds saving, bonding, and AI. One complete route. | Playable demo | Design SECOND |
| **Alpha** | Unlocks progression tree and environmental hazards. | Alpha milestone | Design THIRD |
| **Full Vision** | Audio, multiple routes, menus, and release polish. | Release | Design as needed |

---

## Dependency Map

### Foundation Layer (no dependencies)

1. `MonsterData` — Serves as the database template resource for all monster entities.
2. `InventorySystem` — Holds gathered ingredients and camping items.
3. `SaveManager` — Manages browser cookie loading and saving of player/monster stats.

### Core Layer (depends on foundation)

1. `GridMovement` — Moves the player on the grid.
2. `BattleEngine` — Runs battles; depends on `MonsterData` to load player/enemy combat stats.
3. `BondManager` — Tracks relationship tiers; depends on `MonsterData` and `SaveManager`.
4. `RecipeDatabase` — Defines recipe lists; depends on `InventorySystem` and `SaveManager`.

### Feature Layer (depends on core)

1. `CampManager` — Handles pitching campsite; depends on `BondManager`, `RecipeDatabase`, and `InventorySystem`.
2. `TalentTree` — Unlocks player skills; depends on `BondManager` and `SaveManager`.
3. `WildAI` — Guides enemy battle choices; depends on `BattleEngine`.
4. `FieldHazards` — Restricts route paths; depends on `GridMovement`, `TalentTree`, and `MonsterData`.

### Presentation Layer (depends on features)

1. `BattleUI` — Battle overlay; depends on `BattleEngine` and `WildAI`.
2. `CampUI` — Camp interaction UI; depends on `CampManager`.

---

## Recommended Design Order

This is the order in which we will write the Game Design Documents (GDDs).

| Order | System | Priority | Layer | Agent(s) | Est. Effort |
|-------|--------|----------|-------|----------|-------------|
| 1 | `MonsterData` | MVP | Foundation | game-designer | S (1 session) |
| 2 | `InventorySystem` | MVP | Foundation | game-designer | S (1 session) |
| 3 | `GridMovement` | MVP | Core | game-designer | M (2 sessions) |
| 4 | `BattleEngine` | MVP | Core | game-designer | L (3+ sessions) |
| 5 | `CampManager` | MVP | Feature | game-designer | M (2 sessions) |
| 6 | `BattleUI` | MVP | Presentation | ui-programmer, game-designer | M (2 sessions) |
| 7 | `SaveManager` | Vertical Slice | Foundation | devops-engineer, game-designer | S (1 session) |
| 8 | `BondManager` | Vertical Slice | Core | game-designer | M (2 sessions) |
| 9 | `RecipeDatabase` | Vertical Slice | Core | game-designer | S (1 session) |
| 10 | `WildAI` | Vertical Slice | Core | ai-programmer, game-designer | M (2 sessions) |
| 11 | `CampUI` | Vertical Slice | Presentation | ui-programmer, game-designer | M (2 sessions) |
| 12 | `TalentTree` | Alpha | Feature | game-designer | M (2 sessions) |
| 13 | `FieldHazards` | Alpha | Feature | game-designer | S (1 session) |

---

## Circular Dependencies

*   **None found**: The dependency graph forms a clean Directed Acyclic Graph (DAG).

---

## High-Risk Systems

| System | Risk Type | Risk Description | Mitigation |
|--------|-----------|-----------------|------------|
| `BattleEngine` | Design | Simple turn-based move stances may become repetitive or dull. | Include simple status effects and build distinct Action Point modifiers to keep battles dynamic. |
| `CampManager` | Design | Preparing food at camps might feel like boring micro-management chores. | Keep cooking simple, visual, and highly interactive (using small, playful quick-time event inputs). |

---

## Progress Tracker

| Metric | Count |
|--------|-------|
| Total systems identified | 13 |
| Design docs started | 6 |
| Design docs reviewed | 0 |
| Design docs approved | 0 |
| MVP systems designed | 6/6 |
| Vertical Slice systems designed | 0/5 |

---

## Next Steps

- [x] Review and approve this systems enumeration
- [ ] Design MVP-tier systems first (use `/design-system [system-name]`)
- [ ] Run `/design-review` on each completed GDD
- [ ] Run `/gate-check systems-design` when MVP systems are designed
- [ ] Validate the highest-risk systems with `/vertical-slice` before committing to Production
