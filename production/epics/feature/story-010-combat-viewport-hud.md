# Story-010: Combat Viewport HUD

*   **Epic**: [Feature Layer](file:///Users/cation/Game-Studios/production/epics/feature/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want the combat UI to display active monster cards, health bars, and an Action Point crystal bar that previews move costs when I hover over move options.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Extends Godot `Control` nodes with standard containers, anchoring them to support browser scaling. Connects the `BattleEngine` round states to update the UI components dynamically.

---

## 3. GDD Requirements Addressed
*   **TR-ui-001**: AP cost preview flash (costing $C_{move}$ makes the last $C_{move}$ crystals flash in red).
*   **TR-ui-002**: Smooth HP bar tweens and status overlays.

---

## 4. Acceptance Criteria
*   **GIVEN** the player has 3 AP, **WHEN** hovering over a move costing 2 AP, **THEN** the last 2 AP crystals in the bar flash red.
*   **GIVEN** a companion takes damage, **WHEN** damage resolves, **THEN** the health bar drains smoothly using a Godot Tween over exactly $0.5$ seconds.
*   **GIVEN** a Blocked event, **WHEN** the action executes, **THEN** a bouncy `"BLOCKED!"` text label is spawned above the target sprite.
