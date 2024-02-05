extends ActionLeaf
class_name WalkToCenterOfScreen

@export var entity: Entity
@export var walk_to_position: WalkToPosition

func tick(actor: Node, blackboard: Blackboard):
	# Move towards the center of the screen
	if actor.position.distance_to(walk_to_position.position) <= entity.target_treshold:
		return FAILURE
	
	walk_to_position.position = get_viewport().size / 2
	return SUCCESS