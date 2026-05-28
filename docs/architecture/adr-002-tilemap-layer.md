# ADR-002: Grid-Based TileMapLayer Structure

*   **Status**: Accepted
*   **Date**: 2026-05-28
*   **Author**: Antigravity
*   **Engine Version**: Godot 4.6.3

---

## Context & Decision Drivers

Hearth & Horn is a 2D top-down grid adventure. The movement controller needs to perform fast, coordinate-based checks to answer:
1.  Is the target tile blocked by an obstacle (tree, rock)?
2.  Is the player stepping into tall grass (triggers wild encounter rolls)?
3.  Is the player stepping onto a campsite tile (enables camp pitching)?
4.  Is the target tile a one-way ledge (triggers a jumping leap downward)?

In Godot 4.3+, the single `TileMap` node was deprecated in favor of multiple stacked `TileMapLayer` nodes. Each `TileMapLayer` represents a single coordinate grid. We need to define a consistent technical structure to organize these layers and query their cells.

## Options Considered

### Option A: Stacked TileMapLayer Nodes (Recommended)
This approach structures the map scene tree with multiple `TileMapLayer` nodes acting as children of a root `Node2D`. For example:
*   `GroundLayer` (walkable dirt, grass pathways)
*   `GrassLayer` (tall grass cells)
*   `ObstacleLayer` (trees, cliffs)
*   `CampLayer` (campsite icons)

The player script queries cell metadata using Godot's custom data layers (`TileMapPattern` / custom cell data).

*   **Pros**:
    *   Aligns with Godot 4.6.3 best practices.
    *   No legacy `TileMap` deprecation warnings.
    *   Custom data layers (e.g. `"walkable"` boolean, `"terrain_type"` string) are configured visually in the editor.
*   **Cons**:
    *   Slightly increases the node count in the scene tree.

### Option B: Legacy TileMap Node
This approach uses the old Godot 4.0–4.2 `TileMap` node, which manages multiple internal layers via index parameters in code (e.g., `tile_map.get_cell_source_id(layer_index, coords)`).

*   **Pros**:
    *   One single node in the scene tree.
*   **Cons**:
    *   Triggers deprecation warnings in Godot 4.6.
    *   Less clean coding API, as layer indices are hardcoded integers rather than named node references.

## Chosen Option

**Option A (Stacked TileMapLayer Nodes)** is selected. It utilizes Godot 4.6's modern API and makes tile queries highly readable:

```gdscript
# Player collision check helper
func is_tile_walkable(target_coord: Vector2i) -> bool:
    # 1. Check if an obstacle exists
    var obstacle_cell = obstacle_layer.get_cell_tile_data(target_coord)
    if obstacle_cell and not obstacle_cell.get_custom_data("walkable"):
        return false
        
    # 2. Check base floor layer
    var ground_cell = ground_layer.get_cell_tile_data(target_coord)
    if ground_cell and not ground_cell.get_custom_data("walkable"):
        return false
        
    return true
```

## Consequences

*   **Positive**: Easy to expand. If we add new gameplay tiles (like icy tiles that slide the player), we simply add a custom data layer `"icy"` in the tileset and check it.
*   **Negative**: Map creators must ensure they paint tiles on the correct layers in the editor. Stamping obstacles on the GroundLayer would bypass blockages if not configured carefully.

## Dependencies
*   **Enables**: [ADR-003: Save/Load State with ConfigFile](file:///Users/cation/Game-Studios/docs/architecture/adr-003-save-load-configfile.md) (saving player coordinates mapped to TileMapLayer cells).

## GDD Requirements Addressed
*   **TR-movement-001**: Cardinal step transitions (sliding tweens).
*   **TR-movement-002**: Wall/Tree collision blocking (using `"walkable"` cell checks).
*   **TR-movement-003**: Tall grass encounter steps tracking.
*   **TR-movement-004**: Ledge leaping (detecting `"ledge"` terrain cells).
