extends ActionLeaf
class_name WalkToCenterOfScreen

@export var entity: Entity

func tick(actor: Node, blackboard: Blackboard):
	# Move towards the center of the screen
	actor.velocity.x = 1 if actor.position.x < get_viewport().size.x / 2 else -1
	actor.velocity.y = 1 if actor.position.y < get_viewport().size.y / 2 else -1
	
	return SUCCESS

func interrupt(actor: Node, blackboard: Blackboard):
	entity.character.velocity = Vector2.ZERO
