extends ConditionLeaf
class_name IsInCenterOfScreen

func tick(actor, blackboard: Blackboard):
	var middle = get_viewport().size / 2
	var position = Vector2i(actor.position.round())
	var distance = (middle - position).length()
	
	if distance <= 1:
		return SUCCESS
	
	return FAILURE
