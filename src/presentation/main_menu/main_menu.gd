# src/presentation/main_menu/main_menu.gd
extends Control

## Playable Interactive Demo Runner for Hearth & Horn.
## Integrates Grid Player movement, Grass Encounter chance checks,
## Camp clears (stoking, chores, stew cooking QTEs), and Tactical Stance battles.

enum GameMode { MENU, EXPLORATION, CAMP, BATTLE }
var current_mode: GameMode = GameMode.MENU

# Decoupled system managers
var map: DemoMapContext
var player: GridPlayer
var camp_manager: CampManager
var inventory: Inventory
var active_companions: Array[MonsterData] = []
var active_enemies: Array[MonsterData] = []
var battle_engine: BattleEngine
var battle_ui: BattleUI

# UI nodes
var canvas_layer: CanvasLayer
var screen_container: ColorRect
var font_size: int = 8

# Cooking QTE tracking state
var qte_active: bool = false
var qte_slider_pos: float = 0.0
var qte_slider_dir: float = 1.0

# ─── NESTED GRID CONTEXT ──────────────────────────────────────────────────────
class DemoMapContext:
	extends GridMapContext
	# 9x9 grid coordinates
	var size: Vector2i = Vector2i(9, 9)
	var campsite: Vector2i = Vector2i(4, 4)
	
	func is_walkable(coords: Vector2i) -> bool:
		# Enforce outer borders
		if coords.x <= 0 or coords.x >= size.x - 1 or coords.y <= 0 or coords.y >= size.y - 1:
			return false
		return true
		
	func is_grass(coords: Vector2i) -> bool:
		# Grass patches in columns 2 and 6
		return (coords.x == 2 and coords.y >= 2 and coords.y <= 6) or (coords.x == 6 and coords.y >= 2 and coords.y <= 6)
		
	func is_campsite(coords: Vector2i) -> bool:
		return coords == campsite

# ─── INITIALIZATION ───────────────────────────────────────────────────────────
func _ready() -> void:
	# Enforce absolute native GBA stretch aspect ratios
	get_viewport().content_scale_size = Vector2i(240, 160)
	get_viewport().content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	get_viewport().content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
	
	canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	
	# Draw absolute black border screen backing
	screen_container = ColorRect.new()
	screen_container.color = Color(0.08, 0.05, 0.05) # dark cozy brown
	screen_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas_layer.add_child(screen_container)
	
	_initialize_game_state()
	_draw_current_state()

func _initialize_game_state() -> void:
	# 1. Map and Player
	map = DemoMapContext.new()
	player = GridPlayer.new()
	player.map_context = map
	player.grid_position = Vector2i(3, 4) # start left of campsite
	player.facing_direction = Vector2i.RIGHT
	player.current_state = GridPlayer.State.IDLE
	player._ready()
	add_child(player)
	
	# 2. Inventory and Items
	inventory = Inventory.new()
	var wood := ItemData.new()
	wood.item_id = "wood"
	wood.display_name = "Firewood"
	wood.category = "Fuel"
	inventory.add_item(wood, 3) # start with 3 wood
	
	var berry := ItemData.new()
	berry.item_id = "berry"
	berry.display_name = "Cozy Berry"
	berry.category = "Ingredient"
	inventory.add_item(berry, 5) # start with 5 cozy berries
	
	# 3. Monster Companions
	var sprout := MonsterData.new()
	sprout.monster_id = "sprout"
	sprout.display_name = "Sprout"
	sprout.elemental_type = "Grass"
	sprout.camp_role = "Gatherer"
	sprout.base_hp = 60
	sprout.initialize_runtime_state()
	sprout.current_hp = 45 # slightly damaged
	sprout.fatigue = 40 # slightly tired
	active_companions.append(sprout)
	
	var pyra := MonsterData.new()
	pyra.monster_id = "pyra"
	pyra.display_name = "Pyra"
	pyra.elemental_type = "Fire"
	pyra.camp_role = "Fire-Starter"
	pyra.base_hp = 50
	pyra.base_speed = 2 # Speedier!
	pyra.initialize_runtime_state()
	active_companions.append(pyra)
	
	# 4. Managers
	camp_manager = CampManager.new()
	camp_manager.campfire_fuel = 80.0 # 66% stoked

	# Bind player encounter and campsite triggers
	player.camp_pitched_triggered.connect(func():
		_pitch_camp_action()
	)
	player.encounter_triggered.connect(func():
		_trigger_battle_action()
	)

# ─── MODE TRANSITIONS ─────────────────────────────────────────────────────────
func _pitch_camp_action() -> void:
	if camp_manager.pitch_camp(player):
		current_mode = GameMode.CAMP
		_draw_current_state()

func _trigger_battle_action() -> void:
	current_mode = GameMode.BATTLE
	
	# Seed wild encounter
	active_enemies.clear()
	var wild_puff := MonsterData.new()
	wild_puff.monster_id = "puff"
	wild_puff.display_name = "Wild Puff"
	wild_puff.elemental_type = "Normal"
	wild_puff.base_hp = 40
	wild_puff.initialize_runtime_state()
	active_enemies.append(wild_puff)
	
	# Spawn BattleEngine and BattleUI
	battle_engine = BattleEngine.new()
	battle_engine.start_battle(active_companions, active_enemies)
	
	battle_ui = BattleUI.new()
	screen_container.add_child(battle_ui)
	battle_ui.initialize_ap_display(battle_engine.current_round_ap)
	
	_draw_current_state()

# ─── DRAW RENDERING LOOP ──────────────────────────────────────────────────────
func _clear_screen() -> void:
	for child in screen_container.get_children():
		child.queue_free()

func _draw_current_state() -> void:
	_clear_screen()
	match current_mode:
		GameMode.MENU:
			_render_menu_mode()
		GameMode.EXPLORATION:
			_render_exploration_mode()
		GameMode.CAMP:
			_render_camp_mode()
		GameMode.BATTLE:
			_render_battle_mode()

# ─── MODE 1: GBA MAIN MENU ────────────────────────────────────────────────────
func _render_menu_mode() -> void:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.grow_horizontal = 2
	vbox.grow_vertical = 2
	screen_container.add_child(vbox)
	
	var title := Label.new()
	title.text = "HEARTH & HORN"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.theme_type_variation = "HeaderLarge"
	title.add_theme_color_override("font_color", Color.ORANGE)
	vbox.add_child(title)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 15)
	vbox.add_child(spacer)
	
	var prompt := Label.new()
	prompt.text = "[ PRESS ENTER TO START DEMO ]"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(prompt)
	
	# Micro-animation: glow/flash prompt text
	var tween: Tween = create_tween()
	tween.tween_property(prompt, "modulate:a", 0.3, 0.6)
	tween.tween_property(prompt, "modulate:a", 1.0, 0.6)
	tween.set_loops()

# ─── MODE 2: EXPLORATION FIELD GRID ───────────────────────────────────────────
func _render_exploration_mode() -> void:
	# Container for the grid arena
	var center_box := CenterContainer.new()
	center_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_container.add_child(center_box)
	
	var grid_panel := PanelContainer.new()
	center_box.add_child(grid_panel)
	
	var cell_grid := GridContainer.new()
	cell_grid.columns = map.size.x
	grid_panel.add_child(cell_grid)
	
	# Draw cell blocks
	for y in range(map.size.y):
		for x in range(map.size.x):
			var cell_coords := Vector2i(x, y)
			var cell := ColorRect.new()
			cell.custom_minimum_size = Vector2(12, 12)
			
			if cell_coords == player.grid_position:
				# Player character block
				cell.color = Color.SADDLE_BROWN
			elif map.is_campsite(cell_coords):
				# Camp logs block
				cell.color = Color.DARK_RED
			elif map.is_grass(cell_coords):
				# Tall grass block
				cell.color = Color.FOREST_GREEN
			elif not map.is_walkable(cell_coords):
				# Border obstacles block
				cell.color = Color.DIM_GRAY
			else:
				# General path block
				cell.color = Color(0.25, 0.22, 0.20)
				
			cell_grid.add_child(cell)
			
	# Top indicator panel
	var helper_panel := PanelContainer.new()
	helper_panel.custom_minimum_size = Vector2(240, 20)
	helper_panel.position = Vector2(0, 140)
	screen_container.add_child(helper_panel)
	
	var helper_text := Label.new()
	helper_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if map.is_campsite(player.grid_position):
		helper_text.text = "Campsite! Press ENTER to Pitch Camp"
		helper_text.add_theme_color_override("font_color", Color.YELLOW)
	elif map.is_grass(player.grid_position):
		helper_text.text = "Tall Grass... step count: %d" % player.steps_in_grass
	else:
		helper_text.text = "Arrows: Move cardinally"
		
	helper_panel.add_child(helper_text)

# ─── MODE 3: CAMP DASHBOARD ───────────────────────────────────────────────────
func _render_camp_mode() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	screen_container.add_child(margin)
	
	var vbox := VBoxContainer.new()
	margin.add_child(vbox)
	
	# Header title
	var header := Label.new()
	header.text = "CAMP CLEARINGClearing"
	header.add_theme_color_override("font_color", Color.ORANGE)
	vbox.add_child(header)
	
	# Campfire fuel progress bar
	var fuel_label := Label.new()
	fuel_label.text = "Campfire Fuel: %.1f seconds" % camp_manager.campfire_fuel
	vbox.add_child(fuel_label)
	
	var fuel_progress := ProgressBar.new()
	fuel_progress.max_value = camp_manager.max_fuel_capacity
	fuel_progress.value = camp_manager.campfire_fuel
	fuel_progress.custom_minimum_size = Vector2(0, 8)
	vbox.add_child(fuel_progress)
	
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer)
	
	# Chores status
	var chores_label := Label.new()
	var starter: MonsterData = camp_manager.chore_assignments["Fire-Starter"] as MonsterData
	var gatherer: MonsterData = camp_manager.chore_assignments["Gatherer"] as MonsterData
	chores_label.text = "Chores: Fire-Starter: %s | Gatherer: %s" % [
		starter.display_name if starter != null else "None",
		gatherer.display_name if gatherer != null else "None"
	]
	vbox.add_child(chores_label)
	
	# Inventory items
	var inv_label := Label.new()
	inv_label.text = "Backpack: Firewood: %d | Cozy Berries: %d" % [
		1 if inventory.has_item("wood", 1) else 0, # simplified count for HUD
		3 if inventory.has_item("berry", 3) else 0
	]
	vbox.add_child(inv_label)
	
	var spacer2 := Control.new()
	spacer2.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer2)
	
	# Action options
	var opt_vbox := VBoxContainer.new()
	vbox.add_child(opt_vbox)
	
	var opt1 := Label.new()
	opt1.text = "[1] Stoke Fire (Consumes 1 firewood)"
	opt_vbox.add_child(opt1)
	
	var opt2 := Label.new()
	opt2.text = "[2] Assign Chores (Cycle Sprout to Gatherer)"
	opt_vbox.add_child(opt2)
	
	var opt3 := Label.new()
	opt3.text = "[3] Cook Cozy Stew (Timing QTE minigame!)"
	opt_vbox.add_child(opt3)
	
	var opt_exit := Label.new()
	opt_exit.text = "[Esc] Pack up camp and exit"
	opt_exit.add_theme_color_override("font_color", Color.GRAY)
	opt_vbox.add_child(opt_exit)
	
	# Draw QTE visual overlay if active
	if qte_active:
		_draw_qte_minigame_slider(vbox)

func _draw_qte_minigame_slider(parent: Control) -> void:
	var qte_box := PanelContainer.new()
	qte_box.custom_minimum_size = Vector2(200, 30)
	parent.add_child(qte_box)
	
	var vbox := VBoxContainer.new()
	qte_box.add_child(vbox)
	
	var prompt := Label.new()
	prompt.text = "COOKING STEW! Press Space at the Sweet Spot!"
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt.add_theme_color_override("font_color", Color.YELLOW)
	vbox.add_child(prompt)
	
	# Renders a slider tracker: [------|------] where | moves back and forth
	var track_rect := ColorRect.new()
	track_rect.custom_minimum_size = Vector2(200, 6)
	track_rect.color = Color.DIM_GRAY
	vbox.add_child(track_rect)
	
	# Sweet spot (green zone) right in the center (offset 90 to 110)
	var target_zone := ColorRect.new()
	target_zone.custom_minimum_size = Vector2(20, 6)
	target_zone.position = Vector2(90, 0)
	target_zone.color = Color.GREEN
	track_rect.add_child(target_zone)
	
	# Sweeper marker
	var marker := ColorRect.new()
	marker.custom_minimum_size = Vector2(4, 10)
	marker.position = Vector2(qte_slider_pos, -2)
	marker.color = Color.RED
	track_rect.add_child(marker)

# ─── MODE 4: STANCE BATTLE ENGINE ─────────────────────────────────────────────
func _render_battle_mode() -> void:
	# Floating panel status cards
	var layout := HBoxContainer.new()
	layout.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_container.add_child(layout)
	
	var margin_left := MarginContainer.new()
	margin_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(margin_left)
	
	# Left: Player active companion card
	var player_mon := active_companions[0]
	var p_vbox := VBoxContainer.new()
	p_vbox.set_anchors_preset(Control.PRESET_CENTER_LEFT)
	p_vbox.position = Vector2(10, 10)
	margin_left.add_child(p_vbox)
	
	var p_name := Label.new()
	p_name.text = "%s (Lvl 5)" % player_mon.display_name
	p_vbox.add_child(p_name)
	
	var p_hp_label := Label.new()
	p_hp_label.text = "HP: %d/%d" % [player_mon.current_hp, player_mon.base_hp]
	p_vbox.add_child(p_hp_label)
	
	# Re-add HP bar references so BattleUI Tweens update them!
	battle_ui.hp_bar_mon_1 = ProgressBar.new()
	battle_ui.hp_bar_mon_1.max_value = 1.0
	battle_ui.hp_bar_mon_1.value = float(player_mon.current_hp) / float(player_mon.base_hp)
	battle_ui.hp_bar_mon_1.custom_minimum_size = Vector2(80, 6)
	p_vbox.add_child(battle_ui.hp_bar_mon_1)
	
	var p_badge := Label.new()
	p_badge.text = "Stance: " + (battle_ui.stance_badges[0] if battle_ui.stance_badges[0] != "" else "Idle")
	p_badge.add_theme_color_override("font_color", Color.CYAN)
	p_vbox.add_child(p_badge)
	
	# Right: Enemy active card
	var margin_right := MarginContainer.new()
	margin_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(margin_right)
	
	var enemy_mon := active_enemies[0]
	var e_vbox := VBoxContainer.new()
	e_vbox.set_anchors_preset(Control.PRESET_CENTER_RIGHT)
	e_vbox.position = Vector2(130, 10)
	margin_right.add_child(e_vbox)
	
	var e_name := Label.new()
	e_name.text = enemy_mon.display_name
	e_vbox.add_child(e_name)
	
	var e_hp_label := Label.new()
	e_hp_label.text = "HP: %d/%d" % [enemy_mon.current_hp, enemy_mon.base_hp]
	e_vbox.add_child(e_hp_label)
	
	battle_ui.hp_bar_mon_2 = ProgressBar.new()
	battle_ui.hp_bar_mon_2.max_value = 1.0
	battle_ui.hp_bar_mon_2.value = float(enemy_mon.current_hp) / float(enemy_mon.base_hp)
	battle_ui.hp_bar_mon_2.custom_minimum_size = Vector2(80, 6)
	e_vbox.add_child(battle_ui.hp_bar_mon_2)
	
	var e_badge := Label.new()
	e_badge.text = "Stance: Unknown"
	e_badge.add_theme_color_override("font_color", Color.ORANGE)
	e_vbox.add_child(e_badge)
	
	# Dialogue box control keys
	var control_panel := PanelContainer.new()
	control_panel.custom_minimum_size = Vector2(240, 50)
	control_panel.position = Vector2(0, 110)
	screen_container.add_child(control_panel)
	
	var ctrl_vbox := VBoxContainer.new()
	control_panel.add_child(ctrl_vbox)
	
	var ap_label := Label.new()
	ap_label.text = "Shared AP Budget: "
	ctrl_vbox.add_child(ap_label)
	
	var moves_vbox := HBoxContainer.new()
	ctrl_vbox.add_child(moves_vbox)
	
	var btn1 := Label.new()
	btn1.text = "[1] Brute (Tackle - 2 AP)"
	moves_vbox.add_child(btn1)
	
	var btn2 := Label.new()
	btn2.text = "[2] Block (Guard - 1 AP)"
	moves_vbox.add_child(btn2)
	
	var btn3 := Label.new()
	btn3.text = "[3] Counter-Block (1 AP)"
	moves_vbox.add_child(btn3)

# ─── PROCESSING INPUTS & TIMERS ───────────────────────────────────────────────
func _process(delta: float) -> void:
	if current_mode == GameMode.CAMP and qte_active:
		# Tick QTE visual sweeper slider back and forth
		qte_slider_pos += delta * 120.0 * qte_slider_dir
		if qte_slider_pos >= 196.0:
			qte_slider_pos = 196.0
			qte_slider_dir = -1.0
		elif qte_slider_pos <= 0.0:
			qte_slider_pos = 0.0
			qte_slider_dir = 1.0
		_draw_current_state()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		match current_mode:
			GameMode.MENU:
				if event.keycode == KEY_ENTER:
					current_mode = GameMode.EXPLORATION
					_draw_current_state()
			GameMode.EXPLORATION:
				_handle_exploration_keys(event.keycode)
			GameMode.CAMP:
				_handle_camp_keys(event.keycode)
			GameMode.BATTLE:
				_handle_battle_keys(event.keycode)

func _handle_exploration_keys(keycode: int) -> void:
	var move_vector := Vector2i.ZERO
	match keycode:
		KEY_UP:
			move_vector = Vector2i.UP
		KEY_DOWN:
			move_vector = Vector2i.DOWN
		KEY_LEFT:
			move_vector = Vector2i.LEFT
		KEY_RIGHT:
			move_vector = Vector2i.RIGHT
		KEY_ENTER:
			# Press Enter on campsite to pitch camp
			if map.is_campsite(player.grid_position):
				_pitch_camp_action()
			return
			
	if move_vector != Vector2i.ZERO:
		var target := player.grid_position + move_vector
		if map.is_walkable(target):
			player.grid_position = target
			# Progressive encounter accumulator ticks
			if map.is_grass(target):
				player.steps_in_grass += 1
				# Roll chance: 5% per step after 5 buffer steps
				if player.steps_in_grass >= 5:
					var chance := (player.steps_in_grass - 5) * 0.05
					if randf() < chance:
						player.steps_in_grass = 0
						_trigger_battle_action()
						return
			else:
				# Stepping out of grass resets steps
				player.steps_in_grass = 0
			_draw_current_state()

func _handle_camp_keys(keycode: int) -> void:
	if qte_active:
		# If QTE is active, space confirm captures accuracy
		if keycode == KEY_SPACE:
			_resolve_cooking_qte()
		return
		
	match keycode:
		KEY_1:
			# Stoke fire
			if camp_manager.stoke_fire(inventory):
				_draw_current_state()
		KEY_2:
			# Assign chores: toggle Sprout to Gatherer
			var mon := active_companions[0]
			if camp_manager.chore_assignments["Gatherer"] == mon:
				camp_manager.assign_chore(null, "Gatherer")
			else:
				camp_manager.assign_chore(mon, "Gatherer")
			_draw_current_state()
		KEY_3:
			# Cook: start QTE minigame!
			if inventory.has_item("berry", 3):
				qte_slider_pos = 0.0
				qte_slider_dir = 1.0
				qte_active = true
				_draw_current_state()
		KEY_ESCAPE:
			# Exit camp clearing
			camp_manager.exit_camp(player)
			current_mode = GameMode.EXPLORATION
			_draw_current_state()

func _resolve_cooking_qte() -> void:
	qte_active = false
	
	# Determine accuracy based on proximity to center (sweet spot target 90-110)
	var minigame_accuracy := 0.5
	if qte_slider_pos >= 90.0 and qte_slider_pos <= 110.0:
		minigame_accuracy = 1.5 # perfect sweet spot!
	elif qte_slider_pos >= 70.0 and qte_slider_pos <= 130.0:
		minigame_accuracy = 1.0 # good timing
		
	# Helper Fire monster Pyra is in the party
	var pyra := active_companions[1]
	
	var cook_result := camp_manager.cook("cozy_berry_stew", inventory, minigame_accuracy, pyra)
	if cook_result["success"]:
		var meal_quality: String = cook_result["meal_quality"]
		# Feed cooked meal to Sprout
		var sprout := active_companions[0]
		camp_manager.consume_meal(sprout, meal_quality)
		
		# Spawn a floating popup!
		var alert := battle_ui.spawn_feedback_popup(meal_quality + " cooked!", Vector2(30, 50))
		screen_container.add_child(alert)
		
	_draw_current_state()

func _handle_battle_keys(keycode: int) -> void:
	var move_name := ""
	var ap_cost := 0
	var stance_type := ""
	
	match keycode:
		KEY_1:
			move_name = "Tackle"
			ap_cost = 2
			stance_type = "Brute"
		KEY_2:
			move_name = "Defensive Guard"
			ap_cost = 1
			stance_type = "Block"
		KEY_3:
			move_name = "Counter-Strike"
			ap_cost = 1
			stance_type = "Counter-Block"
			
	if move_name != "":
		# Preview spending crystals
		battle_ui.preview_ap_cost(battle_engine.current_round_ap, ap_cost)
		
		# Resolve a quick battle step!
		var player_mon := active_companions[0]
		var enemy_mon := active_enemies[0]
		
		# Update active stance icons
		battle_ui.update_stance_icon(0, stance_type)
		_draw_current_state()
		
		# Await brief delay and execute action logic
		var timer := get_tree().create_timer(0.4)
		timer.timeout.connect(func():
			var damage := 0
			var popup_text := ""
			
			if stance_type == "Block":
				popup_text = "BLOCKED!"
				damage = 0
			elif stance_type == "Counter-Block":
				popup_text = "COUNTERED!"
				damage = 15
				enemy_mon.apply_damage(damage)
			else:
				# Brute
				popup_text = "Tackle hit!"
				damage = 25
				enemy_mon.apply_damage(damage)
				
			# Spawn impact popup above enemy position
			var alert := battle_ui.spawn_feedback_popup(popup_text, Vector2(140, 40))
			screen_container.add_child(alert)
			
			# Animate HP bars
			var tween := battle_ui.update_hp(1, enemy_mon.current_hp, enemy_mon.base_hp)
			
			# Check win trigger
			if enemy_mon.current_hp <= 0:
				tween.finished.connect(func():
					current_mode = GameMode.EXPLORATION
					battle_ui.queue_free()
					_draw_current_state()
				)
			else:
				# Enemy counter-attacks player!
				player_mon.apply_damage(10)
				var p_tween := battle_ui.update_hp(0, player_mon.current_hp, player_mon.base_hp)
				p_tween.finished.connect(func():
					_draw_current_state()
				)
		)
