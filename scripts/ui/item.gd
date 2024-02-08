extends Control


@export var texture: Texture2D
@export var count: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Texture.texture = texture
	$Label.text = str(count)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
