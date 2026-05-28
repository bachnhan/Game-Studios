# Story-004: TileMap Movement

*   **Epic**: [Core Layer](file:///Users/cation/Game-Studios/production/epics/core/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want to use arrow keys to navigate the route maps tile-by-tile with smooth sliding transitions, and bump into obstacles (like trees or walls) when they are in my path.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-002: TileMapLayer Grid](file:///Users/cation/Game-Studios/docs/architecture/adr-002-tilemap-layer.md)
*   **Pattern**: Uses stacked `TileMapLayer` nodes. The movement script queries cell custom data (e.g. `walkable = false` for trees) to decide whether to execute a slide.

---

## 3. GDD Requirements Addressed
*   **TR-movement-001**: Grid cardinally-aligned translations and in-place turning when tap-inputs are registered.
*   **TR-movement-002**: Navigation collision blocking on layers.
*   **TR-movement-004**: Downward one-way ledge hops (leaping 2 tiles forward with a parabolic Y-offset jump).

---

## 4. Acceptance Criteria
*   **GIVEN** an idle player character, **WHEN** the player holds `Right` past `TURN_TAP_THRESHOLD`, **THEN** the character slides smoothly to the adjacent tile over exactly $16 / 64 = 0.25$ seconds.
*   **GIVEN** the tile directly in front of the player contains custom cell data `walkable = false`, **WHEN** the player attempts to walk forward, **THEN** the movement fails, coordinates remain unchanged, and a bump squish animation/sound triggers.
*   **GIVEN** a player character facing a downward ledge tile, **WHEN** they press `Down`, **THEN** they execute a parabolic jumping offset curve and land 2 tiles down, bypassing normal obstacle collision on the ledge cells.
