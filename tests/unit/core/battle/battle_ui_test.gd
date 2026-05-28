# tests/unit/core/battle/battle_ui_test.gd
class_name BattleUITest
extends GdUnitTestSuite

var ui: BattleUI

func before_test() -> void:
	ui = BattleUI.new()
	# Add to tree so tweens can run
	var scene_root: Node = Engine.get_main_loop().current_scene
	if scene_root != null:
		scene_root.add_child(ui)
	else:
		var main_loop: SceneTree = Engine.get_main_loop() as SceneTree
		if main_loop != null:
			main_loop.root.add_child(ui)
	ui._ready()

func after_test() -> void:
	if ui != null and is_instance_valid(ui):
		ui.free()

func test_hp_bar_tween_drains_smoothly() -> void:
	# Initialize HP bar value to full (1.0)
	ui.hp_bar_mon_1.value = 1.0
	
	# Trigger damage update: HP 60 out of 100 -> ratio 0.6
	var tween: Tween = ui.update_hp(0, 60, 100)
	assert_object(tween).is_not_null()
	
	# Await the tween's completion
	await tween.finished
	
	assert_float(ui.hp_bar_mon_1.value).is_equal(0.6)

func test_ap_crystal_cost_preview_modulates_correct_indices() -> void:
	# 4 max AP
	ui.initialize_ap_display(4)
	
	# Hover a 2-AP move when current AP is 3.
	# preview_index_start = 3 - 2 = 1.
	# Crystals:
	# i = 0 (i < 1): Green (active)
	# i = 1 (1 >= 1 and 1 < 3): Red (spent preview)
	# i = 2 (2 >= 1 and 2 < 3): Red (spent preview)
	# i = 3 (3 >= 3): Dim Gray (empty)
	ui.preview_ap_cost(3, 2)
	
	assert_object(ui.ap_crystals[0].modulate).is_equal(Color.GREEN)
	assert_object(ui.ap_crystals[1].modulate).is_equal(Color.RED)
	assert_object(ui.ap_crystals[2].modulate).is_equal(Color.RED)
	assert_object(ui.ap_crystals[3].modulate).is_equal(Color.DIM_GRAY)

func test_feedback_popup_spawns_and_tweens_content() -> void:
	var start_pos := Vector2(100, 100)
	
	# 1. Spawn Blocked popup
	var label_blocked: Label = ui.spawn_feedback_popup("BLOCKED!", start_pos)
	assert_object(label_blocked).is_not_null()
	assert_str(label_blocked.text).is_equal("BLOCKED!")
	assert_object(label_blocked.modulate).is_equal(Color.AQUA)
	assert_object(label_blocked.get_parent()).is_equal(ui.floating_container)
	
	# 2. Spawn Countered popup
	var label_countered: Label = ui.spawn_feedback_popup("COUNTERED!", start_pos)
	assert_object(label_countered).is_not_null()
	assert_str(label_countered.text).is_equal("COUNTERED!")
	assert_object(label_countered.modulate).is_equal(Color.YELLOW)
	
	# 3. Spawn Miss popup
	var label_miss: Label = ui.spawn_feedback_popup("MISS!", start_pos)
	assert_object(label_miss).is_not_null()
	assert_str(label_miss.text).is_equal("MISS!")
	assert_object(label_miss.modulate).is_equal(Color.GRAY)

func test_stance_badges_update_visual_states() -> void:
	ui.update_stance_icon(0, "Block")
	ui.update_stance_icon(1, "Brute")
	
	assert_str(ui.stance_badges[0]).is_equal("Block")
	assert_str(ui.stance_badges[1]).is_equal("Brute")
