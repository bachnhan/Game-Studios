# GdUnit4 test suite for BattleEngine round loops and stance resolution.
# Asserts AP budgets, cost thresholds, Speed ordering, Block/Counter resolution, and defeat.
class_name BattleEngineTest
extends GdUnitTestSuite

var engine: BattleEngine
var player_party: Array[MonsterData] = []
var enemy_party: Array[MonsterData] = []

var move_brute: BattleMove
var move_block: BattleMove
var move_counter: BattleMove

func before_test() -> void:
	engine = BattleEngine.new()
	
	# Set up moves
	move_brute = BattleMove.new()
	move_brute.move_id = "brute"
	move_brute.display_name = "Tackle"
	move_brute.base_power = 20
	move_brute.ap_cost = 1
	move_brute.stance = "Brute Attack"
	
	move_block = BattleMove.new()
	move_block.move_id = "block"
	move_block.display_name = "Defensive Guard"
	move_block.base_power = 0
	move_block.ap_cost = 1
	move_block.stance = "Block"
	
	move_counter = BattleMove.new()
	move_counter.move_id = "counter"
	move_counter.display_name = "Crumple Strike"
	move_counter.base_power = 15
	move_counter.ap_cost = 2
	move_counter.stance = "Counter-Block"
	
	player_party.clear()
	enemy_party.clear()

func after_test() -> void:
	player_party.clear()
	enemy_party.clear()

func _create_test_monster(p_id: String, p_speed: int, p_hp: int = 50, p_atk: int = 10, p_def: int = 10) -> MonsterData:
	var template := MonsterData.new()
	template.monster_id = p_id
	template.base_hp = p_hp
	template.base_speed = p_speed
	template.base_attack = p_atk
	template.base_defense = p_def
	return MonsterFactory.spawn_active(template)

func test_battle_engine_calculates_ap_budget_from_speed() -> void:
	# Arrange
	var p1 := _create_test_monster("mon1", 3)
	var p2 := _create_test_monster("mon2", 1)
	player_party.append(p1)
	player_party.append(p2)
	
	var e1 := _create_test_monster("enemy1", 1)
	enemy_party.append(e1)
	
	# Act
	engine.start_battle(player_party, enemy_party)
	
	# Assert
	assert_int(engine.current_round_ap).is_equal(4) # Speed 3 + Speed 1

func test_battle_engine_validate_ap_limits_on_allocate() -> void:
	# Arrange
	var p1 := _create_test_monster("mon1", 2) # Total round ap is 2
	player_party.append(p1)
	var e1 := _create_test_monster("enemy1", 1)
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	assert_int(engine.current_round_ap).is_equal(2)
	
	# Act - Allocate 2-AP move (succeeds, ap goes to 0)
	var success1 := engine.allocate_player_action(p1, move_counter, e1)
	assert_bool(success1).is_true()
	assert_int(engine.current_round_ap).is_equal(0)
	
	# Act - Attempt to allocate another 1-AP move (should fail, budget empty)
	var success2 := engine.allocate_player_action(p1, move_brute, e1)
	assert_bool(success2).is_false()
	assert_int(engine.current_round_ap).is_equal(0)

func test_battle_engine_resolves_brute_vs_block_deals_zero() -> void:
	# Arrange
	var p1 := _create_test_monster("player", 2)
	player_party.append(p1)
	var e1 := _create_test_monster("enemy", 2)
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	
	# Queued actions: Player Brute Attack vs Enemy Block
	engine.allocate_player_action(p1, move_brute, e1)
	engine.allocate_enemy_action(e1, move_block, p1)
	
	var was_blocked := [false]
	var final_damage := [-1]
	engine.action_resolved.connect(func(actor, move, target, damage, is_blocked, is_countered):
		if actor == p1:
			final_damage[0] = damage
			was_blocked[0] = is_blocked
	)
	
	# Act
	engine.execute_round()
	
	# Assert
	assert_int(final_damage[0]).is_equal(0)
	assert_bool(was_blocked[0]).is_true()

func test_battle_engine_resolves_counter_vs_block_deals_double() -> void:
	# Arrange - Player ATK = 10, Enemy DEF = 10 (base_power 15)
	# Stance multiplier = 2.0. Base bond level 0 (modifier 1.0)
	# Expected damage: 15 * (10 / 10) * 2.0 = 30
	var p1 := _create_test_monster("player", 2)
	player_party.append(p1)
	var e1 := _create_test_monster("enemy", 2)
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	
	# Queued actions: Player Counter-Block vs Enemy Block
	engine.allocate_player_action(p1, move_counter, e1)
	engine.allocate_enemy_action(e1, move_block, p1)
	
	var was_countered := [false]
	var final_damage := [-1]
	engine.action_resolved.connect(func(actor, move, target, damage, is_blocked, is_countered):
		if actor == p1:
			final_damage[0] = damage
			was_countered[0] = is_countered
	)
	
	# Act
	engine.execute_round()
	
	# Assert
	assert_int(final_damage[0]).is_equal(30)
	assert_bool(was_countered[0]).is_true()

func test_battle_engine_resolves_counter_vs_brute_deals_zero() -> void:
	# Arrange
	var p1 := _create_test_monster("player", 2)
	player_party.append(p1)
	var e1 := _create_test_monster("enemy", 2)
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	
	# Queued actions: Player Counter-Block vs Enemy Brute
	engine.allocate_player_action(p1, move_counter, e1)
	engine.allocate_enemy_action(e1, move_brute, p1)
	
	var final_damage := [-1]
	engine.action_resolved.connect(func(actor, move, target, damage, is_blocked, is_countered):
		if actor == p1:
			final_damage[0] = damage
	)
	
	# Act
	engine.execute_round()
	
	# Assert - Misses entirely since target is not blocking
	assert_int(final_damage[0]).is_equal(0)

func test_battle_engine_sorts_resolution_order_by_speed() -> void:
	# Arrange - Player speed 3, Enemy speed 1
	var p1 := _create_test_monster("player", 3)
	player_party.append(p1)
	var e1 := _create_test_monster("enemy", 1)
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	engine.allocate_player_action(p1, move_brute, e1)
	engine.allocate_enemy_action(e1, move_brute, p1)
	
	var actors_executed: Array[MonsterData] = []
	engine.action_resolved.connect(func(actor, move, target, damage, is_blocked, is_countered):
		actors_executed.append(actor)
	)
	
	# Act
	engine.execute_round()
	
	# Assert - Speed 3 resolves before Speed 1
	assert_int(actors_executed.size()).is_equal(2)
	assert_str(actors_executed[0].monster_id).is_equal("player")
	assert_str(actors_executed[1].monster_id).is_equal("enemy")

func test_battle_engine_triggers_defeat_on_party_fainted() -> void:
	# Arrange
	var p1 := _create_test_monster("player", 2, 20) # 20 HP
	player_party.append(p1)
	var e1 := _create_test_monster("enemy", 2, 50, 20, 10) # 20 ATK, will deal 40 damage
	enemy_party.append(e1)
	
	engine.start_battle(player_party, enemy_party)
	
	# Enemy Tackle deals 20 * (20/10) = 40 damage (exceeds player 20 HP)
	engine.allocate_player_action(p1, move_brute, e1)
	engine.allocate_enemy_action(e1, move_brute, p1)
	
	var lost_emitted := [false]
	engine.battle_lost.connect(func(): lost_emitted[0] = true)
	
	# Act
	engine.execute_round()
	
	# Assert
	assert_int(p1.current_hp).is_equal(0)
	assert_bool(lost_emitted[0]).is_true()
