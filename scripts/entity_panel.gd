extends Panel


const Item: Resource = preload("res://scenes/ui/item.tscn")

@export var inventory: FlowContainer

## The entity to display for
var entity: Entity

## The name label on the panel
@onready var name_label: Label = $Name

## The health label on the panel
@onready var health_label: Label = $Health


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right_click"):
		close()
	
	if not is_instance_valid(entity):
		close()
	
	update_labels()


## Update labels with the current information
func update_labels() -> void:
	if not entity:
		return
	
	name_label.text = "%s (%s)" % [entity.entity_name, entity.abv_gender]
	health_label.text = "Health: %s" % entity.health


## Open panel, pauses the game
func open() -> void:
	# Add the inventory items to the ui
	for item_name: Variant in entity.inventory.keys():
		var item: Control = Item.instantiate()
		item.texture = entity.inventory[item_name][0].texture
		item.count = entity.inventory[item_name].size()
		inventory.add_child(item)
	
	show()
	get_tree().paused = true


## Close panel, unpauses the game
func close() -> void:
	hide()
	get_tree().paused = false
	
	# Remove the inventory items
	for child: Control in inventory.get_children():
		child.queue_free()


func _on_control_pressed() -> void:
	entity.toggle_control()
	close()


func _on_damage_pressed() -> void:
	entity.damage(5)
