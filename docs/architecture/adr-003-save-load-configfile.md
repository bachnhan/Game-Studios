# ADR-003: Save/Load State with ConfigFile

*   **Status**: Accepted
*   **Date**: 2026-05-28
*   **Author**: Antigravity
*   **Engine Version**: Godot 4.6.3

---

## Context & Decision Drivers

Hearth & Horn is targeted for web browsers (HTML5 exports) and PC builds. We must persist the player's progress across sessions:
1.  Player's grid coordinates (`Vector2i`) and facing direction.
2.  Inventory items (array of item IDs and counts).
3.  Active monster party instances (current health, fatigue, bond level, XP, and secondary talents).

For web builds, Godot maps the virtual `user://` directory to the browser's IndexedDB. We need a serialization format that is reliable, robust against crashes, and extremely easy to read, write, and maintain for a developer.

## Options Considered

### Option A: Godot ConfigFile API (Recommended)
This approach uses Godot's built-in `ConfigFile` helper to store key-value configurations grouped by sections (like an `.ini` file) saved at `user://savegame.cfg`. ConfigFile natively supports serializing Godot-specific data structures like `Vector2i` and custom array data types.

*   **Pros**:
    *   No type conversion boilerplate; Godot natively converts `Vector2i(5, 12)` to string format and parses it back to a `Vector2i` object automatically upon load.
    *   Organized into sections: `[player]`, `[inventory]`, `[party]`.
    *   Beginner-friendly and highly robust.
*   **Cons**:
    *   Uses INI-style structure instead of standard JSON.

### Option B: Raw JSON Serialization
This approach gathers player data into a nested Godot Dictionary, converts it to a JSON string using `JSON.stringify()`, and writes it as text to `user://savegame.json`. Upon load, it parses the string and casts dictionaries back to data types.

*   **Pros**:
    *   JSON is a standard web data format.
*   **Cons**:
    *   JSON has no native concept of Godot's `Vector2i` coordinates. Coordinates would be saved as dictionaries `{"x": 5, "y": 12}` or arrays `[5, 12]`, requiring manual parsing and casting logic upon load.
    *   Loses type safety during parsing, introducing potential bugs for beginners.

## Chosen Option

**Option A (Godot ConfigFile API)** is selected. It completely eliminates coordinate conversion bugs and dictionary parsing boilerplate, keeping serialization clean and beginner-friendly.

### Serialization Pattern

```gdscript
# SaveManager.gd snippet
func save_game(player_pos: Vector2i, inventory: Inventory, party: Array[MonsterData]) -> void:
    var config = ConfigFile.new()
    
    # 1. Save Player State
    config.set_value("player", "grid_position", player_pos)
    
    # 2. Save Inventory (Array of slot dictionaries)
    var items_array: Array = []
    for slot in inventory.slots:
        if slot.quantity > 0:
            items_array.append({"id": slot.item_data.item_id, "qty": slot.quantity})
    config.set_value("inventory", "items", items_array)
    
    # 3. Save Monster Party
    for i in range(party.size()):
        var mon: MonsterData = party[i]
        var section = "monster_" + str(i)
        config.set_value(section, "id", mon.monster_id)
        config.set_value(section, "hp", mon.current_hp)
        config.set_value(section, "fatigue", mon.fatigue)
        config.set_value(section, "bond_level", mon.bond_level)
        config.set_value(section, "bond_xp", mon.bond_xp)
        
    config.save("user://savegame.cfg")
```

## Consequences

*   **Positive**: Very rapid load times. If we add new stats, we simply add a line of `set_value` and `get_value` without worrying about dictionary structure updates.
*   **Negative**: Save files are stored in a Godot-specific format, but since this is a single-player game, external integrations are unnecessary.

## Dependencies
*   **Depends On**: [ADR-001: Data-Driven Resource Management](file:///Users/cation/Game-Studios/docs/docs/architecture/adr-001-resource-management.md) (uses factory method to rebuild monsters from saved IDs).

## GDD Requirements Addressed
*   **TR-inventory-001**: Save/Load active inventory slot item counts.
*   **TR-monster-data-003**: Persist mutable monster HP, fatigue, and relationship tiers.
*   **TR-movement-005**: Save player coordinate indices on route maps.
