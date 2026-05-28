# Sprint 01 Plan: Foundation & Grid Navigation

*   **Sprint Duration**: 2 weeks
*   **Goal**: Establish data models, custom resources, ConfigFile save system, and 2D grid movement with tall grass encounters.
*   **Priority Tiers**:

## 1. Must Have (Core Loop & Persistence)
*   **Story-001: Monster Resources** ([story-001-monster-resources.md](file:///Users/cation/Game-Studios/production/epics/foundation/story-001-monster-resources.md))
    *   *Task*: Create `MonsterData` custom resource script and initialize factory method duplicates at runtime.
*   **Story-002: Inventory Slots** ([story-002-inventory-slots.md](file:///Users/cation/Game-Studios/production/epics/foundation/story-002-inventory-slots.md))
    *   *Task*: Create `ItemData` resource and `Inventory` resource managing slots.
*   **Story-004: TileMap Movement** ([story-004-tilemap-movement.md](file:///Users/cation/Game-Studios/production/epics/core/story-004-tilemap-movement.md))
    *   *Task*: Set up stacked child `TileMapLayer` nodes and implement cardinal grid sliding tweens.

## 2. Should Have (Features & Polish)
*   **Story-003: Save ConfigFile** ([story-003-save-configfile.md](file:///Users/cation/Game-Studios/production/epics/foundation/story-003-save-configfile.md))
    *   *Task*: Implement ConfigFile save-to-disk logic mapping vectors and slot counts.
*   **Story-005: Grass Encounters** ([story-005-grass-encounters.md](file:///Users/cation/Game-Studios/production/epics/core/story-005-grass-encounters.md))
    *   *Task*: Implement grass step counter, safe buffer steps, and battle engine transition signals.

## 3. Nice to Have
*   None.

---

## Risks & Mitigations
*   *Risk*: Godot 4.6.3 `TileMapLayer` cell coordinate queries might return null if layers are not correctly painted.
*   *Mitigation*: Implement safe coordinate checks and warnings in the movement collision script.
