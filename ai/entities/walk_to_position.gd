extends ActionLeaf
class_name WalkToPosition

@export var entity: Entity
@export var position: Vector2

func tick(actor: Node, blackboard: Blackboard):
	# Move towards the position
	if not position:
		return FAILURE
	
	if actor.position.distance_to(position) <= entity.target_treshold:
		return SUCCESS
	
	actor.velocity = actor.position.direction_to(position)
	return RUNNING