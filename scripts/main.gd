extends Node2D


@export var entity_panel: Panel

# TODO: Remove at some point
var moving := false

@onready var entity: Entity = $Human/Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.entity_panel = entity_panel
	
	$Tree/ResourceNode.setup($Wood/WorldResource)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# TODO: Remove at some point
func _unhandled_input(event):
	if not event.is_released():
		return
	
	if event.as_text() == "0":
		if not is_instance_valid(entity):
			print_debug("The entity is not valid")
			return
		
		if not is_instance_valid($Wood):
			print_debug("The wood body is not valid")
			entity.unset_target()
			return
		
		if moving:
			entity.unset_target()
		else:
			entity.walk_to_and_pickup_resource($Wood/WorldResource)
		
		moving = not moving
	elif event.as_text() == "1":
		if not is_instance_valid(entity):
			print_debug("The entity is not valid")
			return
		
		if not is_instance_valid($Tree):
			print_debug("The tree body is not valid")
			entity.unset_target()
			return
		
		if moving:
			entity.unset_target()
		else:
			entity.walk_to_and_use_resource_node($Tree/ResourceNode)
		
		moving = not moving
