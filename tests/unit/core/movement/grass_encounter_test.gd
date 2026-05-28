# GdUnit4 test suite for tall grass encounter calculations.
# Verifies step tracking, safety buffers, math curves, and movement state locking.
class_name GrassEncounterTest
extends GdUnitTestSuite

# Stub context representing grass patches
class GrassMapContext:
	extends GridMapContext
	
	var grass_tiles: Array[Vector2i] = []
	
	func is_grass(coords: Vector2i) -> bool:
		return coords in grass_tiles
		
	func is_walkable(_coords: Vector2i) -> bool:
		return true

var player: GridPlayer
var map: GrassMapContext

func before_test() -> void:
	player = GridPlayer.new()
	map = GrassMapContext.new()
	player.map_context = map
	player.is_test_mode = true
	player.grid_position = Vector2i(0, 0)
	player._ready()

func after_test() -> void:
	player.free()

func test_step_in_grass_increments_counter() -> void:
	# Arrange - Set up grass pathway at (0, 1) and (0, 2)
	map.grass_tiles.append(Vector2i(0, 1))
	map.grass_tiles.append(Vector2i(0, 2))
	
	# Act - Move player to (0, 1)
	player.test_input = Vector2i(0, 1) # DOWN
	player._process(0.02) # Start moving
	player._process(0.25) # Finish step (0.25s)
	
	# Assert - Player coordinate is (0, 1), step counter = 1
	assert_str(str(player.grid_position)).is_equal(str(Vector2i(0, 1)))
	assert_int(player.steps_in_grass).is_equal(1)
	
	# Act - Take another step to (0, 2)
	player.test_input = Vector2i(0, 1) # DOWN
	player._process(0.02)
	player._process(0.25)
	
	# Assert - Coordinate is (0, 2), step counter = 2
	assert_str(str(player.grid_position)).is_equal(str(Vector2i(0, 2)))
	assert_int(player.steps_in_grass).is_equal(2)

func test_stepping_out_of_grass_resets_counter() -> void:
	# Arrange - (0, 1) is grass, (0, 2) is plain dirt
	map.grass_tiles.append(Vector2i(0, 1))
	
	# Act - Step into grass (0, 1)
	player.test_input = Vector2i(0, 1)
	player._process(0.02)
	player._process(0.25)
	assert_int(player.steps_in_grass).is_equal(1)
	
	# Act - Step out of grass onto (0, 2)
	player.test_input = Vector2i(0, 1)
	player._process(0.02)
	player._process(0.25)
	
	# Assert - Counter resets to 0 immediately
	assert_int(player.steps_in_grass).is_equal(0)

func test_safety_buffer_prevents_rolls_under_five_steps() -> void:
	# Arrange - Long grass strip
	for y in range(1, 10):
		map.grass_tiles.append(Vector2i(0, y))
		
	var check_emitted := false
	player.encounter_checked.connect(func(_s, _c): check_emitted = true)
	
	# Act - Take 4 steps (1 to 4)
	for i in range(4):
		player.test_input = Vector2i(0, 1)
		player._process(0.02)
		player._process(0.25)
		
	# Assert - No rolls checked under safety buffer
	assert_int(player.steps_in_grass).is_equal(4)
	assert_bool(check_emitted).is_false()

func test_encounter_progressive_probability_math() -> void:
	# Arrange - Strip of grass, prevent trigger by forcing test roll to fail
	for y in range(1, 20):
		map.grass_tiles.append(Vector2i(0, y))
	player.test_roll_value = 1.0 # Force roll to fail (100% chance > rate)
	
	var last_checked := [0, 0.0]
	player.encounter_checked.connect(func(steps, chance):
		last_checked[0] = steps
		last_checked[1] = chance
	)
	
	# Act - Take 5 steps (enters grass at y=1, y=5 is step 5)
	for i in range(5):
		player.test_input = Vector2i(0, 1)
		player._process(0.02)
		player._process(0.25)
		
	# Assert - Step 5 is the first roll, chance = (5 - 5) * 0.05 = 0%
	assert_int(player.steps_in_grass).is_equal(5)
	assert_int(last_checked[0]).is_equal(5)
	assert_float(last_checked[1]).is_equal(0.0)
	
	# Act - Take a 6th step (y=6)
	player.test_input = Vector2i(0, 1)
	player._process(0.02)
	player._process(0.25)
	
	# Assert - Step 6, chance = (6 - 5) * 0.05 = 5%
	assert_int(player.steps_in_grass).is_equal(6)
	assert_int(last_checked[0]).is_equal(6)
	assert_float(last_checked[1]).is_equal(0.05)
	
	# Act - Take steps up to step 12
	for i in range(6):
		player.test_input = Vector2i(0, 1)
		player._process(0.02)
		player._process(0.25)
		
	# Assert - Step 12, chance = (12 - 5) * 0.05 = 35% (max capped)
	assert_int(player.steps_in_grass).is_equal(12)
	assert_int(last_checked[0]).is_equal(12)
	assert_float(last_checked[1]).is_equal(0.35)
	
	# Act - Take a 13th step
	player.test_input = Vector2i(0, 1)
	player._process(0.02)
	player._process(0.25)
	
	# Assert - Capped at 35% max limit
	assert_int(player.steps_in_grass).is_equal(13)
	assert_float(last_checked[1]).is_equal(0.35)

func test_successful_roll_triggers_encounter_and_locks_movement() -> void:
	# Arrange - Step 6 in grass (probability is 5%)
	for y in range(1, 10):
		map.grass_tiles.append(Vector2i(0, y))
	
	# Take 5 steps to reach buffer edge
	for i in range(5):
		player.test_input = Vector2i(0, 1)
		player._process(0.02)
		player._process(0.25)
		
	var triggered := [false]
	player.encounter_triggered.connect(func(): triggered[0] = true)
	
	# Force next roll to succeed (test_roll_value = 0.0 is < 5% chance)
	player.test_roll_value = 0.0
	
	# Act - Step 6 (triggers check and rolls success)
	player.test_input = Vector2i(0, 1)
	player._process(0.02)
	player._process(0.25)
	
	# Assert - Triggered signal fired, state locked to INTERACTING, grass counter reset to 0
	assert_bool(triggered[0]).is_true()
	assert_int(player.current_state).is_equal(GridPlayer.State.INTERACTING)
	assert_int(player.steps_in_grass).is_equal(0)
