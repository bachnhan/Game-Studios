# src/core/battle/battle_engine.gd
class_name BattleEngine
extends RefCounted

## Manages 2v2 turn-based combat rounds, AP budgeting, and stance-based resolution.

signal round_started(ap_budget: int)
signal action_resolved(actor: MonsterData, move: BattleMove, target: MonsterData, damage: int, is_blocked: bool, is_countered: bool)
signal battle_won()
signal battle_lost()

# Parties and active deployment
var player_party: Array[MonsterData] = []
var enemy_party: Array[MonsterData] = []

var active_player_monsters: Array[MonsterData] = []
var active_enemy_monsters: Array[MonsterData] = []

# Action Points (AP) state
var current_round_ap: int = 0

# Queued actions for the current round
var allocated_player_actions: Array[BattleAction] = []
var allocated_enemy_actions: Array[BattleAction] = []

## Starts a new battle, deploying the first two healthy monsters from each party.
func start_battle(p_player_party: Array[MonsterData], p_enemy_party: Array[MonsterData]) -> void:
	player_party = p_player_party
	enemy_party = p_enemy_party
	
	active_player_monsters.clear()
	active_enemy_monsters.clear()
	
	_deploy_healthy_monsters(player_party, active_player_monsters)
	_deploy_healthy_monsters(enemy_party, active_enemy_monsters)
	
	start_new_round()

## Deploys up to 2 healthy monsters from the party array to the active list.
func _deploy_healthy_monsters(party: Array[MonsterData], active_list: Array[MonsterData]) -> void:
	# Keep existing healthy active monsters
	var healthy_actives: Array[MonsterData] = []
	for mon in active_list:
		if mon != null and mon.current_hp > 0:
			healthy_actives.append(mon)
	
	active_list.clear()
	active_list.append_array(healthy_actives)
	
	# Populate vacant slots from bench
	for mon in party:
		if active_list.size() >= 2:
			break
		if mon != null and mon.current_hp > 0 and not mon in active_list:
			active_list.append(mon)

## Begins a new combat round, calculating the shared AP budget.
func start_new_round() -> void:
	allocated_player_actions.clear()
	allocated_enemy_actions.clear()
	
	# Calculate AP budget as sum of speeds of active healthy player monsters
	current_round_ap = 0
	for mon in active_player_monsters:
		if mon.current_hp > 0:
			current_round_ap += mon.base_speed
	
	emit_signal("round_started", current_round_ap)

## Allocates a player action, validating and deducting its AP cost.
func allocate_player_action(actor: MonsterData, move: BattleMove, target: MonsterData) -> bool:
	if not actor in active_player_monsters or actor.current_hp <= 0:
		return false
	if move == null or target == null or target.current_hp <= 0:
		return false
	if move.ap_cost > current_round_ap:
		return false
		
	current_round_ap -= move.ap_cost
	var action := BattleAction.new(actor, move, target)
	allocated_player_actions.append(action)
	return true

## Allocates an enemy action (AI allocation, bypasses player AP budget).
func allocate_enemy_action(actor: MonsterData, move: BattleMove, target: MonsterData) -> bool:
	if not actor in active_enemy_monsters or actor.current_hp <= 0:
		return false
	if move == null or target == null or target.current_hp <= 0:
		return false
		
	var action := BattleAction.new(actor, move, target)
	allocated_enemy_actions.append(action)
	return true

## Executes all planned actions in order of speed tiers, resolving stances.
func execute_round() -> void:
	# 1. Combine all actions
	var all_actions: Array[BattleAction] = []
	all_actions.append_array(allocated_player_actions)
	all_actions.append_array(allocated_enemy_actions)
	
	# 2. Sort actions by speed descending. Speed ties are randomized.
	all_actions.sort_custom(func(a: BattleAction, b: BattleAction) -> bool:
		if a.actor.base_speed != b.actor.base_speed:
			return a.actor.base_speed > b.actor.base_speed
		return randf() < 0.5
	)
	
	# 3. Resolve actions sequentially
	for action in all_actions:
		var actor: MonsterData = action.actor
		var move: BattleMove = action.move
		var target: MonsterData = action.target
		
		# Skip if actor fainted mid-round
		if actor.current_hp <= 0:
			continue
			
		# Redirect target if current target fainted
		if target.current_hp <= 0:
			target = _find_alternate_target(actor)
			# If no alternate target, action fails
			if target == null:
				continue
		
		# Resolve stance multiplier
		var defender_stance := _query_monster_active_stance(target, all_actions)
		var stance_mult := 1.0
		var is_blocked := false
		var is_countered := false
		
		if move.stance == "Block":
			# Block itself does no direct damage
			stance_mult = 0.0
		elif defender_stance == "Block":
			if move.stance == "Brute Attack":
				stance_mult = 0.0
				is_blocked = true
			elif move.stance == "Counter-Block":
				stance_mult = 2.0
				is_countered = true
		else: # Defender is Idle, Brute Attack, or Counter-Block
			if move.stance == "Brute Attack":
				stance_mult = 1.0
			elif move.stance == "Counter-Block":
				stance_mult = 0.0 # Counter-Block misses non-blocking targets
		
		# Calculate damage (Formula 2)
		var damage := 0
		if stance_mult > 0.0:
			var defender_def := max(1, target.base_defense)
			var stat_ratio := float(actor.base_attack) / float(defender_def)
			var bond_modifier := 1.0 + float(actor.bond_level) * 0.05
			damage = int(round(float(move.base_power) * stat_ratio * stance_mult * bond_modifier))
			damage = clampi(damage, 1, 999)
			
		target.apply_damage(damage)
		emit_signal("action_resolved", actor, move, target, damage, is_blocked, is_countered)
	
	# 4. End of Round adjustments
	_apply_round_end_fatigue()
	_handle_fainted_and_replacements()
	
	# Check battle termination
	if _is_party_defeated(enemy_party):
		emit_signal("battle_won")
	elif _is_party_defeated(player_party):
		emit_signal("battle_lost")
	else:
		start_new_round()

## Finds an alternate target in the opposing party.
func _find_alternate_target(actor: MonsterData) -> MonsterData:
	var opposing_actives := active_enemy_monsters if actor in active_player_monsters else active_player_monsters
	for mon in opposing_actives:
		if mon != null and mon.current_hp > 0:
			return mon
	return null

## Queries the stance a monster chose for this round based on its allocated action.
func _query_monster_active_stance(monster: MonsterData, round_actions: Array[BattleAction]) -> String:
	for action in round_actions:
		if action.actor == monster:
			return action.move.stance
	return "Idle"

## Adds fatigue (+10) to active deployed monsters.
func _apply_round_end_fatigue() -> void:
	for mon in active_player_monsters:
		if mon.current_hp > 0:
			mon.apply_fatigue(10)
	for mon in active_enemy_monsters:
		if mon.current_hp > 0:
			mon.apply_fatigue(10)

## Cleans fainted active monsters and replaces them from the bench.
func _handle_fainted_and_replacements() -> void:
	_deploy_healthy_monsters(player_party, active_player_monsters)
	_deploy_healthy_monsters(enemy_party, active_enemy_monsters)

## Checks if all monsters in a party are fainted (HP == 0).
func _is_party_defeated(party: Array[MonsterData]) -> bool:
	for mon in party:
		if mon != null and mon.current_hp > 0:
			return false
	return true
