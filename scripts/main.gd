extends Node2D


@export var entity_panel: Panel

# TODO: Remove at some point
var moving := false

@onready var entity: Entity = $Human/Entity

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.entity_panel = entity_panel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# TODO: Remove at some point
func _unhandled_input(event):
	if event.as_text() == "0" and event.is_released():
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
