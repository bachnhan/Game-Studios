# Story-003: Save ConfigFile

*   **Epic**: [Foundation Layer](file:///Users/cation/Game-Studios/production/epics/foundation/EPIC.md)
*   **Status**: Ready
*   **Control Manifest Date**: 2026-05-28
*   **Engine Version**: Godot 4.6.3 (GDScript)

---

## 1. Description
As a player, I want the game to automatically save my coordinates, inventory count, and active monster stats when I choose save in the menu, so that my progress is maintained when I resume play on web browsers.

---

## 2. Technical Design & ADR Context
*   **ADR Referenced**: [ADR-003: Save/Load State with ConfigFile](file:///Users/cation/Game-Studios/docs/architecture/adr-003-save-load-configfile.md)
*   **Pattern**: Uses Godot's native `ConfigFile` class, saving to `user://savegame.cfg`. This maps to IndexedDB on HTML5 builds. Natively serializes types like `Vector2i` directly.

---

## 3. GDD Requirements Addressed
*   **TR-monster-data-003**: Persistence of mutable health, fatigue, and relationship tiers.
*   **TR-inventory-001**: Persistence of active items (slots and quantities).
*   **TR-movement-005**: Persistence of player coordinates and facing direction vector.

---

## 4. Acceptance Criteria
*   **GIVEN** an active game state, **WHEN** `SaveManager.save_game()` is called, **THEN** a `savegame.cfg` file is generated containing sections `[player]`, `[inventory]`, and `[party]` with valid values.
*   **GIVEN** a saved config file on disk, **WHEN** `SaveManager.load_game()` is called, **THEN** all player coordinates, slot counts, and monster HP values are successfully reconstructed.
