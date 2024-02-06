extends Node


@export var entity: Entity
@export var walk_to_position: WalkToPosition
@export var requires_entity: Array[BeehaveNode]


## Passes [member entity] to all nodes in [member requires_entity].
func pass_entity() -> void:
	for node in requires_entity:
		node.entity = entity
