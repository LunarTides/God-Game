extends Control


@export var resource: WorldResource:
	set(new_resource):
		resource = new_resource
		
		if is_inside_tree():
			_update()
		
@export var count: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _update() -> void:
	$Texture.texture = resource.texture
	$Label.text = str(count)
	tooltip_text = resource.name


# TODO: Remove
func _unhandled_input(event: InputEvent) -> void:
	if event.is_released() and event.as_text() == "L":
		if resource.name == "Wood":
			resource = preload("res://resources/resources/stone.tres")
		else:
			resource = preload("res://resources/resources/wood.tres")
