# GdUnit4 test suite for Inventory and ItemData resource logic.
# Tests auto-stacking, stack division, boundaries, and transaction safety.
class_name InventoryTest
extends GdUnitTestSuite

var item_wood: ItemData
var item_berry: ItemData
var item_ore: ItemData

func before_each() -> void:
	# Set up test items
	item_wood = ItemData.new()
	item_wood.item_id = "wood"
	item_wood.display_name = "Firewood"
	item_wood.category = "Fuel"
	item_wood.max_stack = 99
	
	item_berry = ItemData.new()
	item_berry.item_id = "berry"
	item_berry.display_name = "Sweet Berry"
	item_berry.category = "Ingredient"
	item_berry.max_stack = 10
	
	item_ore = ItemData.new()
	item_ore.item_id = "ore"
	item_ore.display_name = "Iron Ore"
	item_ore.category = "Utility"
	item_ore.max_stack = 99

func test_inventory_add_item_stacks_correctly() -> void:
	# Arrange
	var inventory := Inventory.new()
	
	# Act - Add below max stack
	var leftovers := inventory.add_item(item_wood, 50)
	
	# Assert
	assert_int(leftovers).is_equal(0)
	assert_int(inventory.slots.size()).is_equal(1)
	assert_int(inventory.slots[0].quantity).is_equal(50)
	assert_str(inventory.slots[0].item_data.item_id).is_equal("wood")
	
	# Act - Add more of the same item
	leftovers = inventory.add_item(item_wood, 30)
	
	# Assert
	assert_int(leftovers).is_equal(0)
	assert_int(inventory.slots.size()).is_equal(1)
	assert_int(inventory.slots[0].quantity).is_equal(80)

func test_inventory_add_item_splits_across_multiple_slots() -> void:
	# Arrange
	var inventory := Inventory.new()
	
	# Act - Add exceeding max stack limit
	var leftovers := inventory.add_item(item_berry, 15) # max_stack is 10
	
	# Assert
	assert_int(leftovers).is_equal(0)
	assert_int(inventory.slots.size()).is_equal(2)
	assert_int(inventory.slots[0].quantity).is_equal(10)
	assert_int(inventory.slots[1].quantity).is_equal(5)

func test_inventory_add_item_blocks_at_max_slots_and_returns_leftovers() -> void:
	# Arrange
	var inventory := Inventory.new()
	inventory.max_slots = 3 # Constrain capacity limit for easy testing
	
	# Act - Fill slots with unique items
	var leftovers1 := inventory.add_item(item_wood, 10)
	var leftovers2 := inventory.add_item(item_berry, 5)
	var leftovers3 := inventory.add_item(item_ore, 20)
	
	# Assert
	assert_int(leftovers1).is_equal(0)
	assert_int(leftovers2).is_equal(0)
	assert_int(leftovers3).is_equal(0)
	assert_int(inventory.slots.size()).is_equal(3)
	
	# Act - Try to add a 4th unique item type
	var item_stone := ItemData.new()
	item_stone.item_id = "stone"
	item_stone.display_name = "Hard Stone"
	item_stone.category = "Utility"
	item_stone.max_stack = 99
	
	var leftovers4 := inventory.add_item(item_stone, 15)
	
	# Assert - Add blocks, full amount is returned as leftovers
	assert_int(leftovers4).is_equal(15)
	assert_int(inventory.slots.size()).is_equal(3)
	assert_bool(inventory.has_item("stone")).is_false()

func test_inventory_remove_item_is_transactional() -> void:
	# Arrange
	var inventory := Inventory.new()
	inventory.add_item(item_wood, 50)
	
	# Act - Remove more than available
	var success := inventory.remove_item("wood", 60)
	
	# Assert - Transaction rolls back, no quantities changed
	assert_bool(success).is_false()
	assert_int(inventory.slots[0].quantity).is_equal(50)
	
	# Act - Remove exact amount
	success = inventory.remove_item("wood", 50)
	
	# Assert - Success, slot cleared
	assert_bool(success).is_true()
	assert_int(inventory.slots.size()).is_equal(0)

func test_inventory_remove_item_clears_slots_at_zero_quantity() -> void:
	# Arrange
	var inventory := Inventory.new()
	inventory.add_item(item_berry, 15) # creates two slots: [10, 5]
	
	# Act - Remove 8 items (deducts 5 from second slot, purging it, and 3 from first slot)
	var success := inventory.remove_item("berry", 8)
	
	# Assert
	assert_bool(success).is_true()
	assert_int(inventory.slots.size()).is_equal(1)
	assert_int(inventory.slots[0].quantity).is_equal(7)

func test_inventory_has_item_checks_total_quantity() -> void:
	# Arrange
	var inventory := Inventory.new()
	inventory.add_item(item_berry, 8)
	inventory.add_item(item_berry, 6) # two slots: [10, 4]
	
	# Act & Assert
	assert_bool(inventory.has_item("berry", 5)).is_true()
	assert_bool(inventory.has_item("berry", 14)).is_true()
	assert_bool(inventory.has_item("berry", 15)).is_false()

func test_inventory_sort_orders_slots_correctly() -> void:
	# Arrange
	var inventory := Inventory.new()
	inventory.add_item(item_ore, 20) # Category: Utility
	inventory.add_item(item_berry, 5) # Category: Ingredient
	inventory.add_item(item_wood, 10) # Category: Fuel
	
	# Act - Sort (Fuel < Ingredient < Utility alphabetically)
	inventory.sort_inventory()
	
	# Assert
	assert_str(inventory.slots[0].item_data.category).is_equal("Fuel")
	assert_str(inventory.slots[1].item_data.category).is_equal("Ingredient")
	assert_str(inventory.slots[2].item_data.category).is_equal("Utility")
