extends Node2D

@export var entity_panel: Panel

@onready var entity: Entity = $Human/Entity
var moving := false

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.entity_panel = entity_panel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event.as_text() == "0" and event.is_released():
		if moving:
			entity.unset_target()
		else:
			entity.set_target($Node2D)
		
		moving = not moving
		entity.generate_name()
