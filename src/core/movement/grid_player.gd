# src/core/movement/grid_player.gd
class_name GridPlayer
extends Node2D

## Signal emitted when the character completes a tile-to-tile movement.
signal moved(new_position: Vector2i)

## Signal emitted when the character turns in place.
signal turned(new_direction: Vector2i)

## Signal emitted when the character attempts to walk into an obstacle.
signal bump_triggered(position: Vector2i, direction: Vector2i)

## Signal emitted when the character initiates a ledge hop.
signal ledge_hopped(start_position: Vector2i, end_position: Vector2i)

## Signal emitted when a grass encounter check is performed.
signal encounter_checked(steps: int, chance: float)

## Signal emitted when a wild monster battle encounter is triggered.
signal encounter_triggered()

const TILE_SIZE: int = 16
const MOVE_SPEED: float = 64.0
const TURN_TAP_THRESHOLD: float = 0.10

# Grass encounter tuning constants
const MIN_SAFE_STEPS: int = 5
const ENCOUNTER_ACCUMULATOR: float = 0.05
const MAX_ENCOUNTER_CHANCE: float = 0.35

enum State { IDLE, TURNING, MOVING, LEDGE_HOPPING, BLOCKED, INTERACTING }

var current_state: State = State.IDLE
var grid_position: Vector2i = Vector2i.ZERO
var target_position: Vector2i = Vector2i.ZERO
var facing_direction: Vector2i = Vector2i.DOWN

# Timers and progress tracking
var move_percent: float = 0.0
var step_timer: float = 0.0
var turn_timer: float = 0.0

# Input buffering for smooth consecutive moves
var buffered_input: Vector2i = Vector2i.ZERO

# Decoupled map context injected at runtime
var map_context: GridMapContext

# Test mode hooks to simulate key presses without OS input
var is_test_mode: bool = false
var test_input: Vector2i = Vector2i.ZERO

# Grass encounter runtime state
var steps_in_grass: int = 0
var test_roll_value: float = -1.0

func _ready() -> void:
	# Synchronize visual Node2D position with grid coordinates on start
	position = Vector2(grid_position * TILE_SIZE)

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			_handle_idle_state(delta)
		State.TURNING:
			_handle_turning_state(delta)
		State.MOVING:
			_handle_moving_state(delta)
		State.LEDGE_HOPPING:
			_handle_ledge_hopping_state(delta)
		State.BLOCKED:
			_handle_blocked_state(delta)
		State.INTERACTING:
			pass

func _handle_idle_state(_delta: float) -> void:
	# 1. Process buffered input if available
	var next_input := buffered_input
	buffered_input = Vector2i.ZERO
	if next_input != Vector2i.ZERO:
		if next_input != facing_direction:
			facing_direction = next_input
			emit_signal("turned", facing_direction)
		_attempt_move(next_input)
		return
	
	# 2. Check for active keyboard/gamepad inputs
	var input := _get_input_direction()
	if input != Vector2i.ZERO:
		if input != facing_direction:
			facing_direction = input
			emit_signal("turned", facing_direction)
			current_state = State.TURNING
			turn_timer = 0.0
		else:
			_attempt_move(input)

func _handle_turning_state(delta: float) -> void:
	turn_timer += delta
	var input := _get_input_direction()
	
	# If input released before threshold, return to IDLE
	if input == Vector2i.ZERO:
		current_state = State.IDLE
		return
	
	# If player changes active key, update direction and reset timer
	if input != facing_direction:
		facing_direction = input
		emit_signal("turned", facing_direction)
		turn_timer = 0.0
		return
	
	# If held past tap threshold, initiate grid step
	if turn_timer >= TURN_TAP_THRESHOLD:
		_attempt_move(facing_direction)

func _handle_moving_state(delta: float) -> void:
	step_timer += delta
	var step_duration: float = float(TILE_SIZE) / MOVE_SPEED
	move_percent = clamp(step_timer / step_duration, 0.0, 1.0)
	
	# Interpolate visual screen position
	var start_pos := Vector2(grid_position * TILE_SIZE)
	var end_pos := Vector2(target_position * TILE_SIZE)
	position = start_pos.lerp(end_pos, move_percent)
	
	# Buffer inputs in the final 20% of the movement step
	if move_percent >= 0.8:
		var next_input := _get_input_direction()
		if next_input != Vector2i.ZERO:
			buffered_input = next_input
			
	if move_percent >= 1.0:
		grid_position = target_position
		emit_signal("moved", grid_position)
		_check_grass_encounter()
		if current_state != State.INTERACTING:
			_on_step_completed()

func _handle_ledge_hopping_state(delta: float) -> void:
	step_timer += delta
	var hop_duration: float = 0.35 # Ledge hop takes slightly longer
	move_percent = clamp(step_timer / hop_duration, 0.0, 1.0)
	
	# Interpolate linear position
	var start_pos := Vector2(grid_position * TILE_SIZE)
	var end_pos := Vector2(target_position * TILE_SIZE)
	position = start_pos.lerp(end_pos, move_percent)
	
	# Add parabolic jumping arc offset
	var jump_height: float = 12.0
	position.y += -sin(move_percent * PI) * jump_height
	
	if move_percent >= 1.0:
		grid_position = target_position
		position = Vector2(grid_position * TILE_SIZE)
		emit_signal("moved", grid_position)
		_check_grass_encounter()
		if current_state != State.INTERACTING:
			current_state = State.IDLE

func _handle_blocked_state(delta: float) -> void:
	step_timer += delta
	var bump_duration: float = 0.15
	move_percent = clamp(step_timer / bump_duration, 0.0, 1.0)
	
	# Visual displacement knock animation
	var bump_offset: float = 4.0
	var displacement := sin(move_percent * PI) * bump_offset
	position = Vector2(grid_position * TILE_SIZE) + Vector2(facing_direction) * displacement
	
	if move_percent >= 1.0:
		position = Vector2(grid_position * TILE_SIZE)
		current_state = State.IDLE

func _attempt_move(direction: Vector2i) -> void:
	var target := grid_position + direction
	
	var walkable := true
	var ledge := false
	
	if map_context != null:
		walkable = map_context.is_walkable(target)
		# Check if the target tile represents a one-way ledge in the moving direction
		ledge = map_context.is_ledge(target, direction)
		
	if ledge:
		current_state = State.LEDGE_HOPPING
		target_position = grid_position + direction * 2
		move_percent = 0.0
		step_timer = 0.0
		emit_signal("ledge_hopped", grid_position, target_position)
	elif walkable:
		current_state = State.MOVING
		target_position = target
		move_percent = 0.0
		step_timer = 0.0
	else:
		current_state = State.BLOCKED
		move_percent = 0.0
		step_timer = 0.0
		emit_signal("bump_triggered", grid_position, direction)

func _on_step_completed() -> void:
	# 1. First prioritize buffered inputs
	var next_input := buffered_input
	buffered_input = Vector2i.ZERO
	if next_input != Vector2i.ZERO:
		if next_input != facing_direction:
			facing_direction = next_input
			emit_signal("turned", facing_direction)
		_attempt_move(next_input)
		return
		
	# 2. Check if the player continues to hold the same key
	var current_input := _get_input_direction()
	if current_input != Vector2i.ZERO:
		if current_input != facing_direction:
			facing_direction = current_input
			emit_signal("turned", facing_direction)
			current_state = State.TURNING
			turn_timer = 0.0
		else:
			_attempt_move(current_input)
	else:
		current_state = State.IDLE

func _get_input_direction() -> Vector2i:
	if is_test_mode:
		return test_input
	if Input.is_action_pressed("ui_right"):
		return Vector2i(1, 0)
	if Input.is_action_pressed("ui_left"):
		return Vector2i(-1, 0)
	if Input.is_action_pressed("ui_down"):
		return Vector2i(0, 1)
	if Input.is_action_pressed("ui_up"):
		return Vector2i(0, -1)
	return Vector2i.ZERO

func _check_grass_encounter() -> void:
	if map_context != null and map_context.is_grass(grid_position):
		steps_in_grass += 1
		_roll_grass_encounter()
	else:
		steps_in_grass = 0

func _roll_grass_encounter() -> void:
	if steps_in_grass < MIN_SAFE_STEPS:
		return
	
	var chance := (steps_in_grass - MIN_SAFE_STEPS) * ENCOUNTER_ACCUMULATOR
	chance = min(chance, MAX_ENCOUNTER_CHANCE)
	
	emit_signal("encounter_checked", steps_in_grass, chance)
	
	var roll := randf()
	if test_roll_value >= 0.0:
		roll = test_roll_value
		
	if roll < chance:
		current_state = State.INTERACTING
		emit_signal("encounter_triggered")
		steps_in_grass = 0
