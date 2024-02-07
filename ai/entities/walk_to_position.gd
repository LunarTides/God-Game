extends ActionLeaf
class_name WalkToPosition


@export var entity: Entity
@export var position: Vector2


func tick(actor: Node, blackboard: Blackboard) -> int:
	# Move towards the position
	if not position:
		return FAILURE
	
	if actor.position.distance_to(position) <= entity.target_threshold:
		entity.emit_target_reached(position)
		return SUCCESS
	
	actor.velocity = actor.position.direction_to(position)
	return RUNNING
