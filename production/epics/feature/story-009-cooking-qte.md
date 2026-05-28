# Story-009: Cooking QTE

*   **Epic**: [Feature Layer](file:///Users/cation/Game-Studios/production/epics/feature/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want to assign my companions to chores based on their camp roles, and cook delicious stews using gathered ingredients by playing a timing slider minigame.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Implements task loops for chores, and a timing check script that maps the sweep offset of a slider bar to a quality score multiplier.

---

## 3. GDD Requirements Addressed
*   **TR-camp-002**: Chore assignments, cooking ingredients consumption, and timing-based quality checks.

---

## 4. Acceptance Criteria
*   **GIVEN** a cooking minigame, **WHEN** the player hits the sweet spot for a total `minigame_accuracy = 1.5` with a helper monster of efficiency `base_efficiency = 1.0`, **THEN** the cooked item resolves to a `"Cozy Masterpiece"`.
*   **GIVEN** a successful cook action, **WHEN** complete, **THEN** the required ingredients (e.g. 3 Cozy Berries) are deducted from the inventory.
