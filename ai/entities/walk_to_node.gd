extends ActionLeaf
class_name WalkToNode

@export var treshold = 10
@export var node: Node2D

func tick(actor: Node, blackboard: Blackboard):
	# Move towards the node
	if not node:
		return FAILURE
	
	actor.get_node("Entity").target_position = node.global_position
	actor.velocity = actor.position.direction_to(node.global_position)
	
	return SUCCESS

func interrupt(actor: Node, blackboard: Blackboard):
	actor.velocity = Vector2.ZERO
