# src/core/item/item_data.gd
class_name ItemData
extends Resource

## Static template resource representing an item species.
## Stores read-only configuration data for items.

@export_group("Identity")
@export var item_id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export_enum("Ingredient", "Fuel", "Consumable", "Utility") var category: String = "Utility"

@export_group("Stats")
@export var max_stack: int = 99
@export var weight: float = 0.1
@export var camp_value: float = 0.0
@export var icon: Texture2D
