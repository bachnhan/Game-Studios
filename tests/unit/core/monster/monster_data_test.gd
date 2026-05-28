# GdUnit4 test suite for MonsterData resource logic.
# Tests data-driven resource attributes and duplication safety.
class_name MonsterDataTest
extends GdUnitTestSuite

func test_monster_data_creation_has_default_values() -> void:
	# Arrange & Act
	var monster := MonsterData.new()
	
	# Assert
	assert_str(monster.monster_id).is_equal("")
	assert_str(monster.display_name).is_equal("")
	assert_str(monster.monster_race).is_equal("")
	assert_str(monster.elemental_type).is_equal("Normal")
	assert_int(monster.base_hp).is_equal(50)
	assert_int(monster.base_attack).is_equal(10)
	assert_int(monster.base_defense).is_equal(10)
	assert_int(monster.base_speed).is_equal(1)
	assert_str(monster.camp_role).is_equal("Gatherer")
	assert_float(monster.work_efficiency).is_equal(1.0)
	
	# Verify runtime state is uninitialized (defaults to 0)
	assert_int(monster.current_hp).is_equal(0)
	assert_int(monster.fatigue).is_equal(0)
	assert_int(monster.bond_level).is_equal(0)
	assert_int(monster.bond_xp).is_equal(0)

func test_monster_data_initialization_sets_runtime_hp() -> void:
	# Arrange
	var monster := MonsterData.new()
	monster.base_hp = 85
	
	# Act
	monster.initialize_runtime_state()
	
	# Assert
	assert_int(monster.current_hp).is_equal(85)
	assert_int(monster.fatigue).is_equal(0)
	assert_int(monster.bond_level).is_equal(0)
	assert_int(monster.bond_xp).is_equal(0)

func test_monster_factory_spawn_active_isolates_memory() -> void:
	# Arrange
	var template := MonsterData.new()
	template.monster_id = "sprout_01"
	template.base_hp = 60
	template.initialize_runtime_state()
	
	# Act
	var active_instance := MonsterFactory.spawn_active(template)
	
	# Assert
	assert_object(active_instance).is_not_null()
	assert_object(active_instance).is_not_same(template)
	assert_str(active_instance.monster_id).is_equal("sprout_01")
	assert_int(active_instance.current_hp).is_equal(60)
	
	# Act - Mutate active companion values
	active_instance.apply_damage(15)
	active_instance.apply_fatigue(10)
	
	# Assert - Base template remains completely unmodified
	assert_int(template.current_hp).is_equal(60)
	assert_int(template.fatigue).is_equal(0)
	
	# Assert - Active instance contains the modified state
	assert_int(active_instance.current_hp).is_equal(45)
	assert_int(active_instance.fatigue).is_equal(10)

func test_monster_data_apply_damage_clamps_at_zero() -> void:
	# Arrange
	var monster := MonsterData.new()
	monster.base_hp = 50
	monster.initialize_runtime_state()
	
	# Act
	monster.apply_damage(60)
	
	# Assert
	assert_int(monster.current_hp).is_equal(0)

func test_monster_data_apply_damage_clamps_at_max() -> void:
	# Arrange
	var monster := MonsterData.new()
	monster.base_hp = 50
	monster.initialize_runtime_state()
	monster.current_hp = 30
	
	# Act - Negative damage (healing)
	monster.apply_damage(-10)
	
	# Assert
	assert_int(monster.current_hp).is_equal(40)
	
	# Act - Healing past base HP limit
	monster.apply_damage(-20)
	
	# Assert
	assert_int(monster.current_hp).is_equal(50)

func test_monster_data_apply_fatigue_clamps_at_zero() -> void:
	# Arrange
	var monster := MonsterData.new()
	monster.initialize_runtime_state()
	monster.apply_fatigue(15)
	
	# Act - Negative fatigue
	monster.apply_fatigue(-20)
	
	# Assert
	assert_int(monster.fatigue).is_equal(0)
