# tests/unit/core/camp/camp_manager_test.gd
class_name CampManagerTest
extends GdUnitTestSuite

# Test double for GridMapContext to stub map layout.
class TestMapContext:
	extends GridMapContext
	var campsite_tiles: Array[Vector2i] = []
	
	func is_campsite(coords: Vector2i) -> bool:
		return coords in campsite_tiles


var player: GridPlayer
var map: TestMapContext
var manager: CampManager
var inventory: Inventory
var item_wood: ItemData

func before_test() -> void:
	player = GridPlayer.new()
	map = TestMapContext.new()
	player.map_context = map
	player.is_test_mode = true
	player.grid_position = Vector2i.ZERO
	player.current_state = GridPlayer.State.IDLE
	player._ready()
	
	manager = CampManager.new()
	inventory = Inventory.new()
	
	item_wood = ItemData.new()
	item_wood.item_id = "wood"
	item_wood.display_name = "Firewood"
	item_wood.category = "Fuel"
	item_wood.max_stack = 99

func after_test() -> void:
	if player != null:
		player.free()

func test_pitch_camp_only_on_campsite_tile() -> void:
	# 1. Coordinate (0, 0) is not a campsite
	var success := manager.pitch_camp(player)
	assert_bool(success).is_false()
	assert_bool(manager.is_camp_active).is_false()
	assert_int(player.current_state).is_equal(GridPlayer.State.IDLE)
	
	# 2. Mark (0, 0) as campsite
	map.campsite_tiles.append(Vector2i.ZERO)
	success = manager.pitch_camp(player)
	assert_bool(success).is_true()
	assert_bool(manager.is_camp_active).is_true()
	assert_int(player.current_state).is_equal(GridPlayer.State.INTERACTING)
	
	# 3. Exit camp
	manager.exit_camp(player)
	assert_bool(manager.is_camp_active).is_false()
	assert_int(player.current_state).is_equal(GridPlayer.State.IDLE)

func test_stoke_fire_consumes_wood_resets_fuel() -> void:
	manager.campfire_fuel = 48.0 # 40% of 120s
	
	# Try stoking with empty inventory
	var success := manager.stoke_fire(inventory)
	assert_bool(success).is_false()
	assert_float(manager.campfire_fuel).is_equal(48.0)
	
	# Add wood and stoke
	inventory.add_item(item_wood, 1)
	success = manager.stoke_fire(inventory)
	assert_bool(success).is_true()
	assert_float(manager.campfire_fuel).is_equal(120.0)
	assert_bool(inventory.has_item("wood")).is_false() # wood consumed

func test_tick_fuel_decreases_over_time_and_fire_starter_slows_decay() -> void:
	# Active camp required for ticking fuel
	manager.is_camp_active = true
	
	# No Fire-Starter: decays normally
	manager.tick_fuel(10.0)
	assert_float(manager.campfire_fuel).is_equal(110.0)
	
	# Create and assign a valid Fire-Starter
	var monster := MonsterData.new()
	monster.current_hp = 50
	monster.elemental_type = "Fire"
	
	var success := manager.assign_chore(monster, "Fire-Starter")
	assert_bool(success).is_true()
	
	# Decays at 1/1.2 rate: 12 seconds tick -> decays exactly 10 seconds
	manager.tick_fuel(12.0)
	assert_float(manager.campfire_fuel).is_equal(100.0)

func test_assign_chore_locks_fainted_validates_roles_prevents_double() -> void:
	# Fainted monster cannot be assigned
	var fainted := MonsterData.new()
	fainted.current_hp = 0
	fainted.elemental_type = "Fire"
	var success := manager.assign_chore(fainted, "Fire-Starter")
	assert_bool(success).is_false()
	
	# Invalid elemental/role match
	var grass := MonsterData.new()
	grass.current_hp = 50
	grass.elemental_type = "Grass"
	grass.camp_role = "Gatherer"
	success = manager.assign_chore(grass, "Fire-Starter")
	assert_bool(success).is_false()
	
	# Valid elemental match
	var fire := MonsterData.new()
	fire.current_hp = 50
	fire.elemental_type = "Fire"
	success = manager.assign_chore(fire, "Fire-Starter")
	assert_bool(success).is_true()
	assert_object(manager.chore_assignments["Fire-Starter"]).is_equal(fire)
	
	# Cannot assign Fire monster to Water-Purifier (wrong type/role)
	success = manager.assign_chore(fire, "Water-Purifier")
	assert_bool(success).is_false()
	
	success = manager.assign_chore(fire, "Gatherer")
	assert_bool(success).is_true()
	assert_object(manager.chore_assignments["Gatherer"]).is_equal(fire)
	assert_object(manager.chore_assignments["Fire-Starter"]).is_null() # unassigned from previous chore

func test_rest_companions_fatigue_and_hp_recovery() -> void:
	# Setup campsite active and stoked
	manager.is_camp_active = true
	manager.campfire_fuel = 120.0
	
	# Companion 1: resting, fainted (fatigue 100, current HP 20 out of 100)
	var resting_mon := MonsterData.new()
	resting_mon.base_hp = 100
	resting_mon.current_hp = 20
	resting_mon.fatigue = 100
	
	# Case A: Rest for 2 segments with a stoked campfire and no warder
	# fatigue restored = 2 * (25 * 1.5 * 1.0) = 75
	# HP restored = 2 * (100 * 0.20 * 1.0) = 40
	manager.rest_companions([resting_mon], 2)
	
	assert_int(resting_mon.fatigue).is_equal(25)
	assert_int(resting_mon.current_hp).is_equal(60)
	
	# Case B: Rest with stoked fire and Warder active
	# fatigue restored = 2 * (25 * 1.5 * 1.2) = 90
	var warder_mon := MonsterData.new()
	warder_mon.current_hp = 50
	warder_mon.camp_role = "Warder"
	
	var success := manager.assign_chore(warder_mon, "Warder")
	assert_bool(success).is_true()
	
	var resting_mon_2 := MonsterData.new()
	resting_mon_2.base_hp = 100
	resting_mon_2.current_hp = 20
	resting_mon_2.fatigue = 100
	
	manager.rest_companions([resting_mon_2], 2)
	assert_int(resting_mon_2.fatigue).is_equal(10)
	
	# Case C: Rest with stoked fire, no warder, but Water-Purifier active
	# fatigue restored = 2 * (25 * 1.5 * 1.0) = 75
	# HP restored = 2 * (100 * 0.20 * 1.5) = 60
	manager.assign_chore(null, "Warder") # clear warder
	var purifier_mon := MonsterData.new()
	purifier_mon.current_hp = 50
	purifier_mon.elemental_type = "Water"
	
	success = manager.assign_chore(purifier_mon, "Water-Purifier")
	assert_bool(success).is_true()
	
	var resting_mon_3 := MonsterData.new()
	resting_mon_3.base_hp = 100
	resting_mon_3.current_hp = 20
	resting_mon_3.fatigue = 100
	
	manager.rest_companions([resting_mon_3], 2)
	assert_int(resting_mon_3.fatigue).is_equal(25)
	assert_int(resting_mon_3.current_hp).is_equal(80)
	
	# Case D: Helper assigned to active chore gets Bond XP, does not rest fatigue/HP
	var worker_mon := MonsterData.new()
	worker_mon.base_hp = 100
	worker_mon.current_hp = 20
	worker_mon.fatigue = 50
	worker_mon.elemental_type = "Fire"
	worker_mon.bond_xp = 0
	
	success = manager.assign_chore(worker_mon, "Fire-Starter")
	assert_bool(success).is_true()
	
	manager.rest_companions([worker_mon], 2)
	assert_int(worker_mon.fatigue).is_equal(50)
	assert_int(worker_mon.current_hp).is_equal(20)
	assert_int(worker_mon.bond_xp).is_equal(10)

func test_cooking_accuracy_and_monster_efficiency_computes_masterpiece() -> void:
	# Add 5 berries to inventory
	var item_berry := ItemData.new()
	item_berry.item_id = "berry"
	item_berry.display_name = "Sweet Berry"
	item_berry.category = "Ingredient"
	item_berry.max_stack = 99
	
	var leftovers := inventory.add_item(item_berry, 5)
	assert_int(leftovers).is_equal(0)
	
	# Helper monster with efficiency 1.0
	var helper := MonsterData.new()
	helper.current_hp = 50
	helper.work_efficiency = 1.0
	
	# 1. Cook with perfect accuracy (1.5) -> quality_score = 1.0 * 1.5 = 1.5 -> Cozy Masterpiece
	var result := manager.cook("cozy_berry_stew", inventory, 1.5, helper)
	assert_bool(result["success"]).is_true()
	assert_str(result["meal_quality"]).is_equal("Cozy Masterpiece")
	assert_float(result["quality_score"]).is_equal(1.5)
	assert_bool(inventory.has_item("berry", 3)).is_false() # 3 berries consumed (2 left)
	
	# 2. Cook with good accuracy (1.2) -> quality_score = 1.0 * 1.2 = 1.2 -> Good Meal
	inventory.add_item(item_berry, 3) # add back to cook again
	result = manager.cook("cozy_berry_stew", inventory, 1.2, helper)
	assert_bool(result["success"]).is_true()
	assert_str(result["meal_quality"]).is_equal("Good Meal")
	assert_float(result["quality_score"]).is_equal(1.2)
	
	# 3. Cook with poor accuracy (0.5) -> quality_score = 1.0 * 0.5 = 0.5 -> Bland Meal
	inventory.add_item(item_berry, 3)
	result = manager.cook("cozy_berry_stew", inventory, 0.5, helper)
	assert_bool(result["success"]).is_true()
	assert_str(result["meal_quality"]).is_equal("Bland Meal")
	assert_float(result["quality_score"]).is_equal(0.5)

func test_cooking_bland_meal_when_fuel_zero() -> void:
	var item_berry := ItemData.new()
	item_berry.item_id = "berry"
	item_berry.display_name = "Sweet Berry"
	item_berry.category = "Ingredient"
	item_berry.max_stack = 99
	inventory.add_item(item_berry, 5)
	
	var helper := MonsterData.new()
	helper.current_hp = 50
	helper.work_efficiency = 1.0
	
	# Empty fuel
	manager.campfire_fuel = 0.0
	
	# Cooking simple recipe when cold always results in Bland Meal (score forced to 0.5)
	var result := manager.cook("cozy_berry_stew", inventory, 1.5, helper)
	assert_bool(result["success"]).is_true()
	assert_str(result["meal_quality"]).is_equal("Bland Meal")

func test_consume_meal_applies_hp_fatigue_and_bond_xp() -> void:
	var monster := MonsterData.new()
	monster.base_hp = 100
	monster.current_hp = 10
	monster.fatigue = 80
	monster.bond_xp = 0
	
	# Bland Meal: -20 fatigue, +10% base_hp (10 HP), +2 Bond XP
	var success := manager.consume_meal(monster, "Bland Meal")
	assert_bool(success).is_true()
	assert_int(monster.fatigue).is_equal(60)
	assert_int(monster.current_hp).is_equal(20)
	assert_int(monster.bond_xp).is_equal(2)
	
	# Good Meal: -50 fatigue, +30% base_hp (30 HP), +5 Bond XP
	success = manager.consume_meal(monster, "Good Meal")
	assert_bool(success).is_true()
	assert_int(monster.fatigue).is_equal(10)
	assert_int(monster.current_hp).is_equal(50)
	assert_int(monster.bond_xp).is_equal(7)

func test_consume_meal_fainted_monster_locks() -> void:
	var fainted := MonsterData.new()
	fainted.base_hp = 100
	fainted.current_hp = 0
	fainted.fatigue = 80
	fainted.bond_xp = 0
	
	# Bland and Good meals are rejected for fainted monsters
	var success := manager.consume_meal(fainted, "Bland Meal")
	assert_bool(success).is_false()
	assert_int(fainted.current_hp).is_equal(0)
	
	success = manager.consume_meal(fainted, "Good Meal")
	assert_bool(success).is_false()
	assert_int(fainted.current_hp).is_equal(0)
	
	# Cozy Masterpiece successfully revives them (+50% base_hp, -100 fatigue, +15 Bond XP)
	success = manager.consume_meal(fainted, "Cozy Masterpiece")
	assert_bool(success).is_true()
	assert_int(fainted.current_hp).is_equal(50)
	assert_int(fainted.fatigue).is_equal(0)
	assert_int(fainted.bond_xp).is_equal(15)

func test_gatherer_ticks_and_shelves_items_when_bag_full() -> void:
	# Enable camp
	manager.is_camp_active = true
	
	var item_berry := ItemData.new()
	item_berry.item_id = "berry"
	item_berry.display_name = "Sweet Berry"
	item_berry.category = "Ingredient"
	item_berry.max_stack = 99
	
	# Create and assign a valid Gatherer
	var gatherer := MonsterData.new()
	gatherer.current_hp = 50
	gatherer.elemental_type = "Grass"
	var success := manager.assign_chore(gatherer, "Gatherer")
	assert_bool(success).is_true()
	
	# Set target time to 10 seconds for easier testing
	manager.gatherer_target = 10.0
	
	# Tick progress by 8.0s -> no items spawned yet
	manager.tick_gathering(8.0, inventory, item_berry)
	assert_float(manager.gatherer_progress).is_equal(8.0)
	assert_bool(inventory.has_item("berry")).is_false()
	
	# Tick by another 4.0s (total 12.0s) -> 1 item spawned, progress wraps to 2.0s
	manager.tick_gathering(4.0, inventory, item_berry)
	assert_float(manager.gatherer_progress).is_equal(2.0)
	assert_bool(inventory.has_item("berry", 1)).is_true()
	assert_int(manager.camp_shelf.size()).is_equal(0)
	
	# Make inventory completely full by using slot limit (we'll set max_slots to 1)
	inventory.max_slots = 1
	# The slot already has 1 berry. Let's fill the stack to its max limit (max stack is 99, but let's change max_stack to 1 for this test)
	item_berry.max_stack = 1
	
	# Now, inventory has 1 item, slot is full, and max slots is 1. Inventory is completely full!
	# Tick by another 10.0 seconds -> should spawn item, fail to insert to inventory, and append to camp shelf!
	manager.tick_gathering(10.0, inventory, item_berry)
	assert_float(manager.gatherer_progress).is_equal(2.0)
	assert_int(manager.camp_shelf.size()).is_equal(1)
	assert_str(manager.camp_shelf[0]).is_equal("berry")
	
	# Clear inventory space (increase slots to 2)
	inventory.max_slots = 2
	
	# Claim items from camp shelf
	manager.claim_shelf_items(inventory, item_berry)
	assert_int(manager.camp_shelf.size()).is_equal(0)
	assert_bool(inventory.has_item("berry", 2)).is_true()

