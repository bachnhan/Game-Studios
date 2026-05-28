# src/core/item/inventory.gd
class_name Inventory
extends Resource

## Resource representing the player's item backpack.
## Tracks slots, limits capacity, and handles addition, removal, and sorting.

@export var max_slots: int = 20

## We use Array[InventorySlot] as the backing store.
var slots: Array[InventorySlot] = []

## Adds items to the inventory. Auto-stacks items up to their max_stack limit.
## Opens new slots if there is space.
## Returns the amount of items that could not fit (leftovers).
func add_item(item_data: ItemData, amount: int) -> int:
	if item_data == null or amount <= 0:
		return amount
	
	var remaining: int = amount
	
	# 1. First pass: fill existing non-full stacks of this item
	for slot in slots:
		if slot.item_data.item_id == item_data.item_id:
			var capacity: int = item_data.max_stack - slot.quantity
			if capacity > 0:
				var to_add: int = min(remaining, capacity)
				slot.quantity += to_add
				remaining -= to_add
				if remaining <= 0:
					return 0
	
	# 2. Second pass: open new slots for remaining quantity
	while remaining > 0 and slots.size() < max_slots:
		var to_add: int = min(remaining, item_data.max_stack)
		var new_slot := InventorySlot.new(item_data, to_add)
		slots.append(new_slot)
		remaining -= to_add
	
	return remaining

## Checks if the inventory contains at least [amount] of the given [item_id].
func has_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	var count: int = 0
	for slot in slots:
		if slot.item_data.item_id == item_id:
			count += slot.quantity
			if count >= amount:
				return true
	return false

## Removes [amount] of the given [item_id] from the inventory.
## This is transactional: if there is insufficient quantity, no changes are made and returns false.
func remove_item(item_id: String, amount: int) -> bool:
	if amount <= 0:
		return true
	if not has_item(item_id, amount):
		return false
	
	var remaining_to_remove: int = amount
	var i: int = slots.size() - 1
	while i >= 0 and remaining_to_remove > 0:
		var slot: InventorySlot = slots[i]
		if slot.item_data.item_id == item_id:
			if slot.quantity <= remaining_to_remove:
				remaining_to_remove -= slot.quantity
				slots.remove_at(i)
			else:
				slot.quantity -= remaining_to_remove
				remaining_to_remove = 0
		i -= 1
	
	return true

## Sorts the inventory slots.
## Sorts by category (alphabetically), then by display name (alphabetically),
## and finally by quantity (descending).
func sort_inventory() -> void:
	slots.sort_custom(func(a: InventorySlot, b: InventorySlot) -> bool:
		if a.item_data.category != b.item_data.category:
			return a.item_data.category < b.item_data.category
		if a.item_data.display_name != b.item_data.display_name:
			return a.item_data.display_name < b.item_data.display_name
		return a.quantity > b.quantity
	)
