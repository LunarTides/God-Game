extends Node2D

@export var entity_panel: Panel

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.entity_panel = entity_panel


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
