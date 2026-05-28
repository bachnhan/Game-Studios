# src/core/movement/grid_map_context.gd
class_name GridMapContext
extends RefCounted

## Interface/Context class representing the map grid and cell properties.
## Decouples player coordinate checks from visual TileMapLayer nodes for unit testability.

## Returns true if the coordinate is walkable.
func is_walkable(_coords: Vector2i) -> bool:
	return true

## Returns true if the coordinate has a downward or cardinally facing one-way ledge.
func is_ledge(_coords: Vector2i, _direction: Vector2i) -> bool:
	return false

## Returns true if the coordinate is tall grass.
func is_grass(_coords: Vector2i) -> bool:
	return false

## Returns true if the coordinate is a campsite tile.
func is_campsite(_coords: Vector2i) -> bool:
	return false

