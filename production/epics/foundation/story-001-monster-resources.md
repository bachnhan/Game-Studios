# Story-001: Monster Resources

*   **Epic**: [Foundation Layer](file:///Users/cation/Game-Studios/production/epics/foundation/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a game designer and developer, I want to construct the base `MonsterData` custom resource script to allow creating visual monster templates inside the editor, and implement the memory duplication pattern when initializing active companions.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-001: Resource Management](file:///Users/cation/Game-Studios/docs/architecture/adr-001-resource-management.md)
*   **Pattern**: Custom Godot resources extending `Resource`. To avoid shared memory mutation, every active monster instance must duplicate the template using `.duplicate()` before modifying stats.

---

## 3. GDD Requirements Addressed
*   **TR-monster-data-001**: Inspector-editable fields (base HP, attack, defense, speed, camp role, elemental type).
*   **TR-monster-data-002**: Runtime isolation of mutable properties (current HP, fatigue, bond level, XP).

---

## 4. Acceptance Criteria
*   **GIVEN** a new `MonsterData` resource is created, **WHEN** opened in the Godot inspector, **THEN** all static attributes (base_hp, base_attack, base_speed, element) are editable.
*   **GIVEN** a static template, **WHEN** instantiated via `template.duplicate()`, **THEN** modifying `current_hp` or `fatigue` on the duplicate does not affect the base template values.
