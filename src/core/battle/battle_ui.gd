# src/core/battle/battle_ui.gd
class_name BattleUI
extends Control

## Manages the presentational overlay, HP bar tweens, AP cost previews,
## and floating feedback indicators for combat.

# References to UI components. If null, we'll instantiate them dynamically in a setup method.
var hp_bar_mon_1: Range
var hp_bar_mon_2: Range
var ap_crystals: Array[Control] = []
var floating_container: Control

# Stance badges mapping (monster_index -> stance name)
var stance_badges: Array[String] = ["", ""]

func _ready() -> void:
	_ensure_components()

## Ensures that mock/logical nodes are initialized for headless test safety.
func _ensure_components() -> void:
	if hp_bar_mon_1 == null:
		# Use ProgressBar (which extends Range) as HP bars
		hp_bar_mon_1 = ProgressBar.new()
		add_child(hp_bar_mon_1)
	if hp_bar_mon_2 == null:
		hp_bar_mon_2 = ProgressBar.new()
		add_child(hp_bar_mon_2)
	if floating_container == null:
		floating_container = Control.new()
		add_child(floating_container)

## Initializes the Action Point crystals visual display.
func initialize_ap_display(max_ap: int) -> void:
	_ensure_components()
	# Clear existing crystals
	for crystal in ap_crystals:
		if is_instance_valid(crystal):
			crystal.queue_free()
	ap_crystals.clear()
	
	for i in range(max_ap):
		var crystal := Control.new()
		add_child(crystal)
		ap_crystals.append(crystal)

## Animates a target monster's health bar smoothly from its current value to the new ratio.
## Animates over exactly 0.5 seconds and returns the generated Tween.
func update_hp(monster_index: int, current_hp: int, base_hp: int) -> Tween:
	_ensure_components()
	var hp_bar: Range = hp_bar_mon_1 if monster_index == 0 else hp_bar_mon_2
	var fill_ratio := float(current_hp) / float(base_hp)
	
	# Clamp fill ratio safely between 0.0 and 1.0
	fill_ratio = clamp(fill_ratio, 0.0, 1.0)
	
	var tween := create_tween()
	tween.tween_property(hp_bar, "value", fill_ratio, 0.5)
	return tween

## Previews move cost by modulating the crystals' colors.
## Crystals being spent flash in RED.
## Active remaining budget crystals stay in GREEN.
## Empty / inactive crystals stay in DIM_GRAY.
func preview_ap_cost(current_ap: int, move_ap_cost: int) -> void:
	var max_ap := ap_crystals.size()
	var preview_index_start := current_ap - move_ap_cost
	
	for i in range(max_ap):
		var crystal := ap_crystals[i]
		if i < preview_index_start:
			# Active budget
			crystal.modulate = Color.GREEN
		elif i >= preview_index_start and i < current_ap:
			# Cost preview (spent)
			crystal.modulate = Color.RED
		else:
			# Inactive/empty
			crystal.modulate = Color.DIM_GRAY

## Spawns a floating bouncy label above the target position, animating and fading it out over 0.6 seconds.
func spawn_feedback_popup(text: String, start_pos: Vector2) -> Label:
	_ensure_components()
	var label := Label.new()
	label.text = text
	label.position = start_pos
	floating_container.add_child(label)
	
	# Event color styling
	match text:
		"BLOCKED!":
			label.modulate = Color.AQUA
		"COUNTERED!":
			label.modulate = Color.YELLOW
		"MISS!":
			label.modulate = Color.GRAY
		_:
			label.modulate = Color.WHITE
			
	var tween := create_tween()
	# Upward translation and fade out
	var target_pos := Vector2(start_pos.x, start_pos.y - 30)
	tween.tween_property(label, "position", target_pos, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)
	
	return label

## Updates the stance badge visual indicators.
func update_stance_icon(monster_index: int, stance: String) -> void:
	if monster_index >= 0 and monster_index < stance_badges.size():
		stance_badges[monster_index] = stance
