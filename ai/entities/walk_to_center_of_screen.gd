extends ActionLeaf
class_name WalkToCenterOfScreen

@export var treshold = 10

func tick(actor: Node, blackboard: Blackboard):
	# Move towards the center of the screen
	#actor.velocity.x = 1 if actor.position.x < get_viewport().size.x / 2 else -1
	#actor.velocity.y = 1 if actor.position.y < get_viewport().size.y / 2 else -1
	
	actor.get_node("Entity").target_position = get_viewport().size / 2
	actor.velocity = actor.position.direction_to(get_viewport().size / 2)
	
	return SUCCESS

func interrupt(actor: Node, blackboard: Blackboard):
	actor.velocity = Vector2.ZERO
