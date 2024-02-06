extends Panel


## The entity to display for
var entity: Entity

## The name label on the panel
@onready var name_label: Label = $Name

## The health label on the panel
@onready var health_label: Label = $Health


# Called when the node enters the scene tree for the first time.
func _ready():
	close()


func _process(delta):
	if Input.is_action_just_pressed("right_click"):
		close()
	
	if not is_instance_valid(entity):
		close()
	
	update_labels()


## Update labels with the current information
func update_labels():
	if not entity:
		return
	
	name_label.text = "%s (%s)" % [entity.entity_name, entity.abv_gender]
	health_label.text = "Health: %s" % entity.health


## Open panel, pauses the game
func open():
	show()
	get_tree().paused = true


## Close panel, unpauses the game
func close():
	hide()
	get_tree().paused = false


func _on_control_pressed():
	entity.toggle_control()
	close()


func _on_damage_pressed():
	entity.damage(5)
