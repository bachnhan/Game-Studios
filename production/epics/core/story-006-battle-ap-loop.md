# Story-006: Battle AP Loop

*   **Epic**: [Core Layer](file:///Users/cation/Game-Studios/production/epics/core/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want combat to deploy my first two healthy companions as a tag team, calculating a shared turn Action Point (AP) budget based on their Speed stats, so that I can allocate points to choose moves.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Reads speed stats from the duplicated active companion structures and instantiates a state machine managing battle turn steps: Planning Phase -> Action Phase -> Resolution.

---

## 3. GDD Requirements Addressed
*   **TR-battle-001**: Active 2v2 companion deployment, speed-based AP budgeting (Speed 1–3, sum 2–6), and AP allocation boundaries.

---

## 4. Acceptance Criteria
*   **GIVEN** combat starts with Active Mon 1 (Speed 3) and Active Mon 2 (Speed 1), **WHEN** the round Planning Phase begins, **THEN** the shared round AP budget is set to exactly 4.
*   **GIVEN** a planning phase, **WHEN** allocating moves to companions, **THEN** moves are validated against the remaining AP, preventing allocation if costs exceed current budget.
*   **GIVEN** the planning phase concludes, **WHEN** entering the action execution phase, **THEN** any leftover unspent AP is discarded and does not carry over to the next round.
