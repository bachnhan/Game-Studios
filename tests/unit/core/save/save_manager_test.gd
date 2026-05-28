# GdUnit4 test suite for SaveManager serialization and deserialization.
# Verifies file generation, full coordinate restoration, inventory rebuilding, and stat preservation.
class_name SaveManagerTest
extends GdUnitTestSuite

var save_manager: SaveManager
var item_wood: ItemData
var item_berry: ItemData
var monster_sprout: MonsterData

func before_test() -> void:
	save_manager = SaveManager.new()
	
	# Set up item templates and register them
	item_wood = ItemData.new()
	item_wood.item_id = "wood"
	item_wood.display_name = "Firewood"
	item_wood.category = "Fuel"
	save_manager.register_item_template(item_wood)
	
	item_berry = ItemData.new()
	item_berry.item_id = "berry"
	item_berry.display_name = "Sweet Berry"
	item_berry.category = "Ingredient"
	save_manager.register_item_template(item_berry)
	
	# Set up monster template and register it
	monster_sprout = MonsterData.new()
	monster_sprout.monster_id = "sprout"
	monster_sprout.display_name = "Sprout"
	monster_sprout.base_hp = 60
	save_manager.register_monster_template(monster_sprout)
	
	# Ensure no legacy save file interferes on start
	_cleanup_save_file()

func after_test() -> void:
	_cleanup_save_file()

func _cleanup_save_file() -> void:
	if FileAccess.file_exists(SaveManager.SAVE_PATH):
		DirAccess.remove_absolute(SaveManager.SAVE_PATH)

func test_save_game_writes_to_disk() -> void:
	# Arrange
	var player_pos := Vector2i(10, 15)
	var player_dir := Vector2i(0, -1) # UP
	var inventory := Inventory.new()
	inventory.add_item(item_wood, 10)
	
	var party: Array[MonsterData] = []
	var companion := MonsterFactory.spawn_active(monster_sprout)
	companion.current_hp = 45
	companion.fatigue = 5
	companion.bond_level = 2
	companion.bond_xp = 120
	party.append(companion)
	
	# Act
	var err := save_manager.save_game(player_pos, player_dir, inventory, party)
	
	# Assert
	assert_int(err).is_equal(OK)
	assert_bool(FileAccess.file_exists(SaveManager.SAVE_PATH)).is_true()

func test_load_game_restores_full_state() -> void:
	# Arrange - Save a test state
	var saved_pos := Vector2i(8, 22)
	var saved_dir := Vector2i(1, 0) # RIGHT
	var saved_inventory := Inventory.new()
	saved_inventory.add_item(item_wood, 25)
	saved_inventory.add_item(item_berry, 8)
	
	var saved_party: Array[MonsterData] = []
	var companion := MonsterFactory.spawn_active(monster_sprout)
	companion.current_hp = 30
	companion.fatigue = 20
	companion.bond_level = 4
	companion.bond_xp = 50
	saved_party.append(companion)
	
	var save_err := save_manager.save_game(saved_pos, saved_dir, saved_inventory, saved_party)
	assert_int(save_err).is_equal(OK)
	
	# Act - Load the state back
	var loaded_pos_wrapper: Array[Vector2i] = []
	var loaded_dir_wrapper: Array[Vector2i] = []
	var loaded_inventory := Inventory.new()
	var loaded_party: Array[MonsterData] = []
	
	var success := save_manager.load_game(loaded_pos_wrapper, loaded_dir_wrapper, loaded_inventory, loaded_party)
	
	# Assert
	assert_bool(success).is_true()
	
	# Verify player state
	assert_int(loaded_pos_wrapper.size()).is_equal(1)
	assert_str(str(loaded_pos_wrapper[0])).is_equal(str(saved_pos))
	assert_int(loaded_dir_wrapper.size()).is_equal(1)
	assert_str(str(loaded_dir_wrapper[0])).is_equal(str(saved_dir))
	
	# Verify inventory state
	assert_int(loaded_inventory.slots.size()).is_equal(2)
	assert_str(loaded_inventory.slots[0].item_data.item_id).is_equal("wood")
	assert_int(loaded_inventory.slots[0].quantity).is_equal(25)
	assert_str(loaded_inventory.slots[1].item_data.item_id).is_equal("berry")
	assert_int(loaded_inventory.slots[1].quantity).is_equal(8)
	
	# Verify party state
	assert_int(loaded_party.size()).is_equal(1)
	assert_str(loaded_party[0].monster_id).is_equal("sprout")
	assert_int(loaded_party[0].current_hp).is_equal(30)
	assert_int(loaded_party[0].fatigue).is_equal(20)
	assert_int(loaded_party[0].bond_level).is_equal(4)
	assert_int(loaded_party[0].bond_xp).is_equal(50)

func test_load_missing_file_returns_false() -> void:
	# Arrange - Ensure no save file exists
	_cleanup_save_file()
	
	# Act
	var loaded_pos: Array[Vector2i] = []
	var loaded_dir: Array[Vector2i] = []
	var loaded_inventory := Inventory.new()
	var loaded_party: Array[MonsterData] = []
	
	var success := save_manager.load_game(loaded_pos, loaded_dir, loaded_inventory, loaded_party)
	
	# Assert
	assert_bool(success).is_false()

func test_load_corrupted_file_returns_false() -> void:
	# Arrange - Write invalid/corrupt data to save path
	var file := FileAccess.open(SaveManager.SAVE_PATH, FileAccess.WRITE)
	file.store_string("THIS IS CORRUPTED GARBAGE DATA NOT IN INI FORMAT")
	file.close()
	
	# Act
	var loaded_pos: Array[Vector2i] = []
	var loaded_dir: Array[Vector2i] = []
	var loaded_inventory := Inventory.new()
	var loaded_party: Array[MonsterData] = []
	
	var success := save_manager.load_game(loaded_pos, loaded_dir, loaded_inventory, loaded_party)
	
	# Assert
	assert_bool(success).is_false()
