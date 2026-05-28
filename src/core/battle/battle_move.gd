# src/core/battle/battle_move.gd
class_name BattleMove
extends Resource

## Custom resource representing a combat move executed in battle.

@export_group("Identity")
@export var move_id: String = ""
@export var display_name: String = ""

@export_group("Combat Stats")
@export var base_power: int = 10
@export var ap_cost: int = 1 ## The Action Point cost to select this move (typically 1 or 2 AP)
@export_enum("Brute Attack", "Block", "Counter-Block") var stance: String = "Brute Attack"
