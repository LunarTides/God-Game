extends Node2D


const HumanResource: WorldEntity = preload("res://resources/entities/human.tres")
const WoodResource: WorldResource = preload("res://resources/resources/wood.tres")
const TreeResource: WorldResourceNode = preload("res://resources/resource_nodes/tree.tres")

@export var entity_panel: Panel

# TODO: Remove at some point
@export var human_spawn_1: Node2D
@export var human_spawn_2: Node2D

var moving: bool = false
var entity: Entity

# TODO: Remove at some point
var wood: StaticBody2D
var tree: StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.entity_panel = entity_panel
	
	# Human 1
	var human1: CharacterBody2D = Game.create_entity(HumanResource)
	human1.position = human_spawn_1.position
	human1.name = "Human1"
	add_child(human1)
	
	entity = human1.get_node("Data")
	
	# Human 2
	var human2: CharacterBody2D = Game.create_entity(HumanResource)
	human2.position = human_spawn_2.position
	human2.name = "Human2"
	add_child(human2)
	
	# Wood
	var wood: StaticBody2D = Game.create_resource(WoodResource)
	wood.position = Vector2(949, 403)
	wood.name = "Wood"
	add_child(wood)
	self.wood = wood
	
	# Tree
	var tree: StaticBody2D = Game.create_resource_node(TreeResource)
	tree.position = Vector2i(172, 481)
	tree.name = "Tree"
	add_child(tree)
	self.tree = tree


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# TODO: Remove at some point
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_released():
		return
	
	if event.as_text() == "0":
		if not is_instance_valid(entity):
			print_debug("The entity is not valid")
			return
		
		if not is_instance_valid(wood):
			print_debug("The wood body is not valid")
			entity.unset_target()
			return
		
		if moving:
			entity.unset_target()
		else:
			entity.walk_to_and_pickup_resource(wood.get_node("Data") as NodeResource)
		
		moving = not moving
	elif event.as_text() == "1":
		if not is_instance_valid(entity):
			print_debug("The entity is not valid")
			return
		
		if not is_instance_valid(tree):
			print_debug("The tree body is not valid")
			entity.unset_target()
			return
		
		if moving:
			entity.unset_target()
		else:
			entity.walk_to_and_use_resource_node(tree.get_node("Data") as ResourceNode)
		
		moving = not moving
