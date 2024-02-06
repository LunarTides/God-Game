extends Node2D


const HumanResource = preload("res://resources/entities/human.tres")
const WoodResource = preload("res://resources/resources/wood.tres")
const TreeResource = preload("res://resources/resource_nodes/tree.tres")

@export var entity_panel: Panel

# TODO: Remove at some point
var moving := false
var entity: Entity


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.entity_panel = entity_panel
	
	# Human 1
	var human1 = Game.create_entity(HumanResource)
	human1.position = $HumanSpawn.position
	human1.name = "Human1"
	add_child(human1)
	
	entity = human1.get_node("Data")
	
	# Human 2
	var human2 = Game.create_entity(HumanResource)
	human2.position = $Human2Spawn.position
	human2.name = "Human2"
	add_child(human2)
	
	# Wood
	var wood = Game.create_resource(WoodResource)
	wood.position = Vector2(949, 403)
	wood.name = "Wood"
	add_child(wood)
	
	# Tree
	var tree = Game.create_resource_node(TreeResource)
	tree.position = Vector2i(172, 481)
	tree.name = "Tree"
	add_child(tree)


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
			print_debug("The tree body is not valid")
			entity.unset_target()
			return
		
		if moving:
			entity.unset_target()
		else:
			entity.walk_to_and_pickup_resource($Wood/Data)
		
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
			entity.walk_to_and_use_resource_node($Tree/Data)
		
		moving = not moving
