# src/core/battle/battle_action.gd
class_name BattleAction
extends RefCounted

## Represents a queued action planned for execution in a combat round.

var actor: MonsterData
var move: BattleMove
var target: MonsterData

func _init(p_actor: MonsterData, p_move: BattleMove, p_target: MonsterData) -> void:
	actor = p_actor
	move = p_move
	target = p_target
