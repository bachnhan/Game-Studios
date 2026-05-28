# src/core/item/inventory_slot.gd
class_name InventorySlot
extends RefCounted

## Container class that pairs an item template with a mutable quantity count.

var item_data: ItemData
var quantity: int = 0

func _init(p_item_data: ItemData, p_qty: int) -> void:
	item_data = p_item_data
	quantity = p_qty
