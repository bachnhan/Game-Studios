# Story-008: Campfire Recovery

*   **Epic**: [Feature Layer](file:///Users/cation/Game-Studios/production/epics/feature/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want to pitch a temporary camp when standing on a campsite tile, stoke the fire with wood to keep my companions warm, and rest them in the tent to restore their health and fatigue.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md), [ADR-002: TileMapLayer Grid](file:///Users/cation/Game-Studios/docs/architecture/adr-002-tilemap-layer.md)
*   **Pattern**: Intercepts player interaction input when standing on campsite cells. The camp loop scales fatigue recovery values based on campfire fuel states.

---

## 3. GDD Requirements Addressed
*   **TR-camp-001**: Campsite interaction, campfire wood stoking, and tent resting recovery formulas.

---

## 4. Acceptance Criteria
*   **GIVEN** a player is on a campsite tile, **WHEN** they press the interact button, **THEN** the map exploration pauses, and the screen transitions to the Camp layout.
*   **GIVEN** a campfire fuel level of 40%, **WHEN** the player consumes 1 wood, **THEN** the wood is deducted from the inventory, and the campfire fuel level resets to exactly 100%.
*   **GIVEN** a resting companion in the tent, **WHEN** resting for 2 segments with a stoked campfire and no warder, **THEN** their fatigue level decreases by exactly $2 \times (25 \times 1.5) = 75$ points.
