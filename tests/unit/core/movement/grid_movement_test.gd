# GdUnit4 test suite for GridPlayer and GridMapContext movement logic.
# Tests tap-to-turn, slide translation, collisions, input buffering, and ledge jumping.
class_name GridMovementTest
extends GdUnitTestSuite

# Test double for GridMapContext to stub map layouts.
class TestMapContext:
	extends GridMapContext
	
	var unwalkable_tiles: Array[Vector2i] = []
	var ledge_tiles: Dictionary = {} # Vector2i -> Vector2i (movement direction that triggers ledge hop)
	var grass_tiles: Array[Vector2i] = []
	
	func is_walkable(coords: Vector2i) -> bool:
		return not coords in unwalkable_tiles
	
	func is_ledge(coords: Vector2i, direction: Vector2i) -> bool:
		if coords in ledge_tiles:
			return ledge_tiles[coords] == direction
		return false
	
	func is_grass(coords: Vector2i) -> bool:
		return coords in grass_tiles

var player: GridPlayer
var map: TestMapContext

func before_each() -> void:
	player = GridPlayer.new()
	map = TestMapContext.new()
	player.map_context = map
	player.is_test_mode = true
	player.grid_position = Vector2i(0, 0)
	player.facing_direction = Vector2i.DOWN
	player._ready()

func after_each() -> void:
	player.free()
	map.free()

func test_tap_turn_updates_direction_in_place() -> void:
	# Arrange - Player faces DOWN. Press RIGHT key.
	player.test_input = Vector2i(1, 0) # RIGHT
	
	# Act - Process one frame (starts turning)
	player._process(0.05)
	
	# Assert - State is TURNING, look direction is RIGHT, grid position is unchanged
	assert_int(player.current_state).is_equal(GridPlayer.State.TURNING)
	assert_str(player.facing_direction).is_equal(Vector2i(1, 0))
	assert_str(player.grid_position).is_equal(Vector2i(0, 0))
	
	# Act - Simulate release of key before TURN_TAP_THRESHOLD (0.10s)
	player.test_input = Vector2i.ZERO
	player._process(0.02)
	
	# Assert - Returns to IDLE, looking RIGHT, still on (0, 0)
	assert_int(player.current_state).is_equal(GridPlayer.State.IDLE)
	assert_str(player.facing_direction).is_equal(Vector2i(1, 0))
	assert_str(player.grid_position).is_equal(Vector2i(0, 0))

func test_held_input_initiates_step_and_translates() -> void:
	# Arrange - Player faces DOWN. Press and hold DOWN key.
	player.test_input = Vector2i(0, 1) # DOWN
	
	# Act - Process one frame (starts step immediately since already facing DOWN)
	player._process(0.02)
	
	# Assert - Transitioned directly to MOVING towards (0, 1)
	assert_int(player.current_state).is_equal(GridPlayer.State.MOVING)
	assert_str(player.target_position).is_equal(Vector2i(0, 1))
	assert_str(player.grid_position).is_equal(Vector2i(0, 0))
	
	# Act - Simulate time stepping forward (0.20s out of 0.25s duration)
	player._process(0.20)
	assert_int(player.current_state).is_equal(GridPlayer.State.MOVING)
	assert_float(player.move_percent).is_equal(0.88)
	
	# Act - Advance past completion
	player._process(0.05)
	
	# Assert - Arrived at (0, 1) and since key is still held, immediately starts next step to (0, 2)
	assert_str(player.grid_position).is_equal(Vector2i(0, 1))
	assert_int(player.current_state).is_equal(GridPlayer.State.MOVING)
	assert_str(player.target_position).is_equal(Vector2i(0, 2))

func test_obstacle_collision_blocks_movement_and_triggers_bump() -> void:
	# Arrange - Set (0, 1) as blocked/unwalkable
	map.unwalkable_tiles.append(Vector2i(0, 1))
	player.test_input = Vector2i(0, 1) # DOWN
	
	var bump_emitted := false
	player.bump_triggered.connect(func(pos, dir): bump_emitted = true)
	
	# Act - Start move
	player._process(0.02)
	
	# Assert - Entered BLOCKED state, bump emitted, coordinates remain (0, 0)
	assert_int(player.current_state).is_equal(GridPlayer.State.BLOCKED)
	assert_bool(bump_emitted).is_true()
	assert_str(player.grid_position).is_equal(Vector2i(0, 0))
	
	# Act - Let bump animation finish (0.15s)
	player._process(0.15)
	
	# Assert - State resets to IDLE
	assert_int(player.current_state).is_equal(GridPlayer.State.IDLE)
	assert_str(player.grid_position).is_equal(Vector2i(0, 0))

func test_ledge_hop_bypasses_collision_and_lands_two_tiles_away() -> void:
	# Arrange - Set (0, 1) as a downward ledge, and make (0, 1) also technically blocked
	# (so normal walking would collide, but a ledge hop will leap over it to 0, 2)
	map.ledge_tiles[Vector2i(0, 1)] = Vector2i.DOWN
	map.unwalkable_tiles.append(Vector2i(0, 1))
	player.test_input = Vector2i(0, 1) # DOWN
	
	var hop_emitted := false
	player.ledge_hopped.connect(func(start, end): hop_emitted = true)
	
	# Act - Press DOWN facing the ledge
	player._process(0.02)
	
	# Assert - Entered LEDGE_HOPPING state, targeting (0, 2), bypassing collision
	assert_int(player.current_state).is_equal(GridPlayer.State.LEDGE_HOPPING)
	assert_bool(hop_emitted).is_true()
	assert_str(player.target_position).is_equal(Vector2i(0, 2))
	
	# Act - Let jump finish (0.35s)
	player._process(0.35)
	
	# Assert - Landed at (0, 2)
	assert_str(player.grid_position).is_equal(Vector2i(0, 2))
	assert_int(player.current_state).is_equal(GridPlayer.State.IDLE)

func test_input_buffering_queues_consecutive_steps() -> void:
	# Arrange - Player moving DOWN to (0, 1)
	player.test_input = Vector2i(0, 1)
	player._process(0.02) # enters MOVING
	
	# Act - Halfway through, player presses RIGHT
	player._process(0.10) # move_percent = 0.48
	player.test_input = Vector2i(1, 0) # RIGHT
	player._process(0.02) # still moving DOWN
	
	# Assert - Buffer should not trigger yet (move_percent < 0.8)
	assert_str(player.buffered_input).is_equal(Vector2i.ZERO)
	
	# Act - Move past 80% mark
	player._process(0.08) # move_percent = 0.88
	player._process(0.01)
	
	# Assert - Now inside buffering window, RIGHT is queued
	assert_str(player.buffered_input).is_equal(Vector2i(1, 0))
	
	# Act - Complete step
	player._process(0.05)
	
	# Assert - Immediately enters next step moving RIGHT from (0, 1) to (1, 1) without stalling
	assert_str(player.grid_position).is_equal(Vector2i(0, 1))
	assert_int(player.current_state).is_equal(GridPlayer.State.MOVING)
	assert_str(player.target_position).is_equal(Vector2i(1, 1))
	assert_str(player.facing_direction).is_equal(Vector2i(1, 0))
