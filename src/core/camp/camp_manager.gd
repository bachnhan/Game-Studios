# src/core/camp/camp_manager.gd
class_name CampManager
extends RefCounted

## Governs campfire safety, monster recovery formulas, and chore assignments in Hearth & Horn.

# Campfire fuel state
var max_fuel_capacity: float = 120.0
var campfire_fuel: float = 120.0
var is_camp_active: bool = false

# Active chore allocations
# Maps chore name (String) to MonsterData or null
var chore_assignments: Dictionary = {
	"Fire-Starter": null,
	"Water-Purifier": null,
	"Gatherer": null,
	"Warder": null
}

# Recipe Database
var recipes: Dictionary = {
	"cozy_berry_stew": {
		"ingredients": {
			"berry": 3
		},
		"display_name": "Cozy Berry Stew",
		"is_complex": false
	}
}

# Gathering State
var gatherer_progress: float = 0.0
var gatherer_target: float = 30.0
var camp_shelf: Array[String] = []

## Validates if a monster is eligible for a specific camp role chore.
## Fainted monsters (HP == 0) cannot perform chores.
func _is_valid_role_monster(monster: MonsterData, role: String) -> bool:
	if monster == null:
		return false
	if monster.current_hp == 0:
		return false
	
	match role:
		"Fire-Starter":
			return monster.elemental_type == "Fire" or monster.camp_role == "Fire-Starter"
		"Water-Purifier":
			return monster.elemental_type == "Water" or monster.camp_role == "Water-Purifier"
		"Gatherer":
			return monster.elemental_type == "Normal" or monster.elemental_type == "Grass" or monster.camp_role == "Gatherer"
		"Warder":
			return monster.camp_role == "Warder"
	return false

## Sets up a temporary camp if standing on a campsite tile.
## Pauses exploration movement by transitioning player to the INTERACTING state.
func pitch_camp(player: GridPlayer) -> bool:
	if player == null or player.map_context == null:
		return false
	
	var map: GridMapContext = player.map_context
	if map.has_method("is_campsite") and map.is_campsite(player.grid_position):
		is_camp_active = true
		player.current_state = GridPlayer.State.INTERACTING
		return true
	
	return false

## Packs up the camp, resuming player map exploration.
func exit_camp(player: GridPlayer) -> void:
	is_camp_active = false
	if player != null:
		player.current_state = GridPlayer.State.IDLE

## Ticks campfire fuel timer down.
## If a valid Fire-Starter chore is assigned, decay is slowed by 20% (multiplied by delta / 1.2).
func tick_fuel(delta: float) -> void:
	if not is_camp_active:
		return
	
	var burn_rate := 1.0
	var fire_starter := chore_assignments["Fire-Starter"] as MonsterData
	if fire_starter != null and _is_valid_role_monster(fire_starter, "Fire-Starter"):
		burn_rate = 1.0 / 1.2
	
	campfire_fuel = clamp(campfire_fuel - delta * burn_rate, 0.0, max_fuel_capacity)

## Stokes the fire by consuming exactly 1 wood item from the player's inventory.
## Resets fuel to 100% (max capacity) on success.
func stoke_fire(inventory: Inventory) -> bool:
	if inventory == null:
		return false
	
	if inventory.has_item("wood", 1):
		var success := inventory.remove_item("wood", 1)
		if success:
			campfire_fuel = max_fuel_capacity
			return true
	
	return false

## Assigns a companion monster to a camp chore.
## Ensures the monster is healthy and eligible for the role.
## Ensures a monster is assigned to at most one chore at a time.
func assign_chore(monster: MonsterData, chore_name: String) -> bool:
	if not chore_name in chore_assignments:
		return false
	
	if monster == null:
		chore_assignments[chore_name] = null
		return true
	
	if monster.current_hp == 0:
		return false
	
	if not _is_valid_role_monster(monster, chore_name):
		return false
	
	# Unassign from any other chore first (one chore at a time)
	for role in chore_assignments:
		if chore_assignments[role] == monster:
			chore_assignments[role] = null
			
	chore_assignments[chore_name] = monster
	return true

## Simulates resting companions in the tent for a given number of segments.
## Active working chore helpers gain Bond XP and do not rest.
## Resting companions recover fatigue and HP based on active camp statuses.
func rest_companions(companions: Array[MonsterData], segments: int) -> void:
	if segments <= 0:
		return
	
	var has_warder := false
	var warder := chore_assignments["Warder"] as MonsterData
	if warder != null and _is_valid_role_monster(warder, "Warder"):
		has_warder = true
		
	var has_purifier := false
	var purifier := chore_assignments["Water-Purifier"] as MonsterData
	if purifier != null and _is_valid_role_monster(purifier, "Water-Purifier"):
		has_purifier = true

	# Multipliers based on active campfire and warder
	var fire_multiplier := 1.5 if campfire_fuel > 0.0 else 1.0
	var ward_multiplier := 1.2 if has_warder else 1.0
	var base_rate := 25.0
	
	var fatigue_restored_per_segment := base_rate * fire_multiplier * ward_multiplier
	var total_fatigue_restored := int(round(segments * fatigue_restored_per_segment))
	
	for mon in companions:
		if mon == null:
			continue
		
		# Check if the companion is currently working a chore
		var is_working := false
		for role in chore_assignments:
			if chore_assignments[role] == mon and _is_valid_role_monster(mon, role):
				is_working = true
				break
		
		if is_working:
			# Chores do not recover fatigue but gain Bond XP
			mon.bond_xp += 5 * segments
		else:
			# Resting companion restores fatigue
			mon.apply_fatigue(-total_fatigue_restored)
			
			# Restore HP: baseline 20% of base_hp per segment, accelerated 1.5x by Water-Purifier helper
			var hp_multiplier := 1.5 if has_purifier else 1.0
			var hp_restored_per_segment := mon.base_hp * 0.20 * hp_multiplier
			var total_hp_restored := int(round(segments * hp_restored_per_segment))
			mon.current_hp = clampi(mon.current_hp + total_hp_restored, 0, mon.base_hp)

## Cooks a recipe using the player's inventory, applying QTE accuracy and active helper efficiencies.
## Deducts ingredients from the inventory on success.
## Returns a Dictionary detailing success state and resulting meal quality.
func cook(recipe_id: String, inventory: Inventory, minigame_accuracy: float, helper: MonsterData = null) -> Dictionary:
	if not recipe_id in recipes:
		return {"success": false, "error": "Unknown recipe: " + recipe_id}
	
	if inventory == null:
		return {"success": false, "error": "Inventory not provided"}
		
	var recipe: Dictionary = recipes[recipe_id]
	var ingredients: Dictionary = recipe["ingredients"]
	
	# Verify ingredients availability
	for item_id in ingredients:
		var qty: int = ingredients[item_id]
		if not inventory.has_item(item_id, qty):
			return {"success": false, "error": "Insufficient ingredients for: " + item_id}
	
	var is_complex: bool = recipe.get("is_complex", false)
	
	# Check campfire fuel for complex recipes
	if is_complex and campfire_fuel <= 0.0:
		return {"success": false, "error": "Campfire is cold! Complex recipe failed."}
	
	# Determine base efficiency
	var base_efficiency := 0.8
	if helper != null:
		base_efficiency = helper.work_efficiency
	else:
		var fire_starter := chore_assignments["Fire-Starter"] as MonsterData
		if fire_starter != null and _is_valid_role_monster(fire_starter, "Fire-Starter"):
			base_efficiency = fire_starter.work_efficiency
	
	# Compute Quality Score
	var quality_score := base_efficiency * minigame_accuracy
	
	# Capped to Bland Meal if campfire fuel is dead (simple recipes)
	if not is_complex and campfire_fuel <= 0.0:
		quality_score = 0.5 # forces Bland Meal
	
	var meal_quality := "Bland Meal"
	if quality_score >= 1.4:
		meal_quality = "Cozy Masterpiece"
	elif quality_score >= 1.0:
		meal_quality = "Good Meal"
		
	# Deduct ingredients (transactional)
	var transaction_success := true
	for item_id in ingredients:
		var qty: int = ingredients[item_id]
		if not inventory.remove_item(item_id, qty):
			transaction_success = false
			break
	
	if not transaction_success:
		return {"success": false, "error": "Failed to consume ingredients from inventory"}
	
	return {
		"success": true,
		"meal_quality": meal_quality,
		"quality_score": quality_score
	}

## Feeds a meal of the given quality to a companion monster, recovering fatigue/HP and increasing Bond XP.
## Fainted monsters can ONLY be revived/fed with a "Cozy Masterpiece".
func consume_meal(monster: MonsterData, meal_quality: String) -> bool:
	if monster == null:
		return false
	
	var is_fainted := monster.current_hp == 0
	if is_fainted and meal_quality != "Cozy Masterpiece":
		return false
	
	match meal_quality:
		"Bland Meal":
			monster.apply_fatigue(-20)
			var hp_restore := int(round(monster.base_hp * 0.10))
			monster.current_hp = clampi(monster.current_hp + hp_restore, 0, monster.base_hp)
			monster.bond_xp += 2
			return true
		"Good Meal":
			monster.apply_fatigue(-50)
			var hp_restore := int(round(monster.base_hp * 0.30))
			monster.current_hp = clampi(monster.current_hp + hp_restore, 0, monster.base_hp)
			monster.bond_xp += 5
			return true
		"Cozy Masterpiece":
			monster.apply_fatigue(-100)
			var hp_restore := int(round(monster.base_hp * 0.50))
			# Instantly cures fainted state: HP is successfully set to the restored HP level
			monster.current_hp = clampi(monster.current_hp + hp_restore, 0, monster.base_hp)
			monster.bond_xp += 15
			return true
			
	return false

## Ticks the gathering chore time progress. If a Gatherer is assigned, compiles progress and finds ingredients.
## Plops found items into the camp shelf if player inventory is full.
func tick_gathering(delta: float, inventory: Inventory, item_template: ItemData) -> void:
	if not is_camp_active:
		return
		
	if item_template == null or inventory == null:
		return
	
	var gatherer := chore_assignments["Gatherer"] as MonsterData
	if gatherer == null or not _is_valid_role_monster(gatherer, "Gatherer"):
		return
		
	gatherer_progress += delta
	while gatherer_progress >= gatherer_target:
		gatherer_progress -= gatherer_target
		# Attempt to add to inventory
		var leftovers := inventory.add_item(item_template, 1)
		if leftovers > 0:
			# Inventory full, place onto camp shelf
			camp_shelf.append(item_template.item_id)

## Attempts to claim all items stored on the temporary camp shelf into the player inventory.
func claim_shelf_items(inventory: Inventory, item_template: ItemData) -> void:
	if inventory == null or item_template == null:
		return
		
	var remaining_items: Array[String] = []
	for item_id in camp_shelf:
		if item_id == item_template.item_id:
			var leftovers := inventory.add_item(item_template, 1)
			if leftovers > 0:
				remaining_items.append(item_id)
		else:
			remaining_items.append(item_id)
	camp_shelf = remaining_items
