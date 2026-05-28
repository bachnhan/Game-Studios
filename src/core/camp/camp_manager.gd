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
	var fire_starter: MonsterData = chore_assignments["Fire-Starter"]
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
	var warder: MonsterData = chore_assignments["Warder"]
	if warder != null and _is_valid_role_monster(warder, "Warder"):
		has_warder = true
		
	var has_purifier := false
	var purifier: MonsterData = chore_assignments["Water-Purifier"]
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
