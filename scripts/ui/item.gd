extends Control


@export var resource: WorldResource:
	set(new_resource):
		resource = new_resource
		
		if is_instance_valid($Texture):
			$Texture.texture = resource.texture
			$Label.text = str(count)
			tooltip_text = resource.name
		
@export var count: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Texture.texture = resource.texture
	$Label.text = str(count)
	tooltip_text = resource.name


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
