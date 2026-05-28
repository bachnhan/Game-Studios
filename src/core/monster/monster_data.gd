# src/core/monster/monster_data.gd
class_name MonsterData
extends Resource

## Static template resource representing a monster species/companion.
## To prevent shared memory mutation, duplicate this resource when spawning active companions.

@export_group("Identity")
@export var monster_id: String = ""
@export var display_name: String = ""
@export var monster_race: String = ""
@export_enum("Grass", "Fire", "Water", "Normal") var elemental_type: String = "Normal"

@export_group("Base Stats")
@export var base_hp: int = 50
@export var base_attack: int = 10
@export var base_defense: int = 10
@export var base_speed: int = 1  ## Action Points contributed per combat round (1 to 3)

@export_group("Campsite Chore Utility")
@export_enum("Fire-Starter", "Water-Purifier", "Gatherer", "Warder") var camp_role: String = "Gatherer"
@export var work_efficiency: float = 1.0

# Runtime mutable state (must be initialized using spawn_active)
var current_hp: int = 0
var fatigue: int = 0
var bond_level: int = 0
var bond_xp: int = 0

## Initializes the runtime mutable state of this monster instance.
## Sets current_hp to base_hp and resets fatigue/bond.
func initialize_runtime_state() -> void:
	current_hp = base_hp
	fatigue = 0
	bond_level = 0
	bond_xp = 0

## Applies damage to the monster, reducing its current HP.
## current_hp is clamped between 0 and base_hp.
func apply_damage(amount: int) -> void:
	current_hp = clampi(current_hp - amount, 0, base_hp)

## Applies fatigue to the monster, increasing its fatigue level.
## fatigue is clamped to be non-negative.
func apply_fatigue(amount: int) -> void:
	fatigue = max(0, fatigue + amount) as int

## Creates a memory-isolated duplicate of this template for runtime companion use,
## initializing its runtime values.
func duplicate_instance() -> MonsterData:
	var instance := duplicate() as MonsterData
	instance.initialize_runtime_state()
	return instance
