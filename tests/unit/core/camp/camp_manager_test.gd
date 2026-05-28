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
