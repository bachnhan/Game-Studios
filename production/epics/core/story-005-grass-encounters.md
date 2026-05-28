# Story-005: Grass Encounters

*   **Epic**: [Core Layer](file:///Users/cation/Game-Studios/production/epics/core/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want to traverse tall grass sections and trigger combat encounters randomly based on step counts, with a safe buffer at the beginning of grass patches.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-002: TileMapLayer Grid](file:///Users/cation/Game-Studios/docs/architecture/adr-002-tilemap-layer.md)
*   **Pattern**: Grid movement script tracks steps taken on tiles whose terrain property is `"Grass"`. It rolls a random chance multiplier calculated from the progressive encounter curve.

---

## 3. GDD Requirements Addressed
*   **TR-movement-003**: Tall grass steps tracking, safe-step padding (5 steps), and incremental combat spawn probability.

---

## 4. Acceptance Criteria
*   **GIVEN** a player steps into a tall grass patch, **WHEN** `steps_in_grass` is less than `MIN_SAFE_STEPS = 5`, **THEN** no wild encounter is ever rolled.
*   **GIVEN** the player has taken 8 steps in grass, **WHEN** they take the next step, **THEN** the encounter probability check uses a calculated value of $(8 - 5) \times 0.05 = 15\%$ chance.
*   **GIVEN** an encounter is triggered, **WHEN** step finishes, **THEN** the exploration loop pauses and the `BattleEngine` is signaled.
