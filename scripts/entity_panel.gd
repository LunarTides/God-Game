extends Panel


var entity: Entity

@onready var name_label: Label = $Name
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


func update_labels():
	if not entity:
		return
	
	name_label.text = "%s (%s)" % [entity.entity_name, entity.abv_gender]
	health_label.text = "Health: %s" % entity.health


func open():
	show()
	get_tree().paused = true


func close():
	hide()
	get_tree().paused = false


func _on_control_pressed():
	entity.toggle_control()
	close()


func _on_damage_pressed():
	entity.damage(5)
