# src/core/monster/monster_factory.gd
class_name MonsterFactory
extends RefCounted

## Factory for creating active runtime monster instances from static templates.
## Leverages the Resource duplication pattern.

## Spawns an active companion instance from a static MonsterData template.
## This prevents shared memory mutation bugs by duplicating the resource.
static func spawn_active(template: MonsterData) -> MonsterData:
	if template == null:
		push_error("Cannot spawn active monster: template is null.")
		return null
	return template.duplicate_instance()
