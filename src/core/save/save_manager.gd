# src/core/save/save_manager.gd
class_name SaveManager
extends RefCounted

## Handles saving and loading player, inventory, and party states using ConfigFile.

const SAVE_PATH := "user://savegame.cfg"

## Registry mapping item_id (String) to static ItemData resource templates.
var item_templates: Dictionary = {}

## Registry mapping monster_id (String) to static MonsterData resource templates.
var monster_templates: Dictionary = {}

## Registers an ItemData template for loading resolution.
func register_item_template(item: ItemData) -> void:
	if item != null and item.item_id != "":
		item_templates[item.item_id] = item

## Registers a MonsterData template for loading resolution.
func register_monster_template(monster: MonsterData) -> void:
	if monster != null and monster.monster_id != "":
		monster_templates[monster.monster_id] = monster

## Saves the active game state to user://savegame.cfg.
func save_game(
	player_pos: Vector2i,
	player_dir: Vector2i,
	inventory: Inventory,
	party: Array[MonsterData]
) -> Error:
	var config := ConfigFile.new()
	
	# 1. Save Player State
	config.set_value("player", "grid_position", player_pos)
	config.set_value("player", "facing_direction", player_dir)
	
	# 2. Save Inventory (Array of slot dictionaries)
	var items_array: Array[Dictionary] = []
	for slot in inventory.slots:
		if slot.quantity > 0:
			items_array.append({
				"id": slot.item_data.item_id,
				"qty": slot.quantity
			})
	config.set_value("inventory", "items", items_array)
	
	# 3. Save Monster Party
	config.set_value("party", "count", party.size())
	for i in range(party.size()):
		var mon := party[i]
		var key_prefix := "monster_" + str(i) + "_"
		config.set_value("party", key_prefix + "id", mon.monster_id)
		config.set_value("party", key_prefix + "hp", mon.current_hp)
		config.set_value("party", key_prefix + "fatigue", mon.fatigue)
		config.set_value("party", key_prefix + "bond_level", mon.bond_level)
		config.set_value("party", key_prefix + "bond_xp", mon.bond_xp)
		
	var err := config.save(SAVE_PATH)
	return err

## Loads the saved game state from user://savegame.cfg.
## Reconstructs player coordinates, inventory slot contents, and companion stats.
## Returns true on success, false if file does not exist or fails to load.
func load_game(
	out_player_pos: Array[Vector2i],
	out_player_dir: Array[Vector2i],
	inventory: Inventory,
	party: Array[MonsterData]
) -> bool:
	var config := ConfigFile.new()
	var err := config.load(SAVE_PATH)
	if err != OK:
		return false
	
	if not config.has_section_key("player", "grid_position"):
		return false
	
	# 1. Load Player State
	if config.has_section_key("player", "grid_position"):
		out_player_pos.clear()
		out_player_pos.append(config.get_value("player", "grid_position") as Vector2i)
	if config.has_section_key("player", "facing_direction"):
		out_player_dir.clear()
		out_player_dir.append(config.get_value("player", "facing_direction") as Vector2i)
		
	# 2. Load Inventory
	inventory.slots.clear()
	var items_array = config.get_value("inventory", "items", [])
	for item_dict in items_array:
		var item_id: String = item_dict.get("id", "")
		var qty: int = item_dict.get("qty", 0)
		if item_id != "" and qty > 0 and item_templates.has(item_id):
			var item_template: ItemData = item_templates[item_id]
			inventory.slots.append(InventorySlot.new(item_template, qty))
			
	# 3. Load Monster Party
	party.clear()
	var count: int = config.get_value("party", "count", 0)
	for i in range(count):
		var key_prefix := "monster_" + str(i) + "_"
		var monster_id: String = config.get_value("party", key_prefix + "id", "")
		if monster_id != "" and monster_templates.has(monster_id):
			var template: MonsterData = monster_templates[monster_id]
			var active_mon := MonsterFactory.spawn_active(template)
			active_mon.current_hp = config.get_value("party", key_prefix + "hp", active_mon.base_hp) as int
			active_mon.fatigue = config.get_value("party", key_prefix + "fatigue", 0) as int
			active_mon.bond_level = config.get_value("party", key_prefix + "bond_level", 0) as int
			active_mon.bond_xp = config.get_value("party", key_prefix + "bond_xp", 0) as int
			party.append(active_mon)
			
	return true
