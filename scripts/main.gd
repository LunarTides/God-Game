extends Node2D


const HumanResource: WorldEntity = preload("res://resources/entities/human.tres")
const WoodResource: WorldResource = preload("res://resources/resources/wood.tres")
const StoneResource: WorldResource = preload("res://resources/resources/stone.tres")
const TreeResource: WorldResourceNode = preload("res://resources/resource_nodes/tree.tres")

@export var entity_panel: Panel

# TODO: Remove at some point
@export var human_spawn_1: Node2D
@export var human_spawn_2: Node2D

var moving: bool = false
var entity: Entity


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Game.entity_panel = entity_panel
	
	# Human 1
	var human1: CharacterBody2D = Game.create_entity(HumanResource)
	human1.position = human_spawn_1.position
	human1.name = "Human1"
	add_child(human1)
	
	entity = Game.get_entity_from_body(human1)
	
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
	
	# Tree
	var tree: StaticBody2D = Game.create_resource_node(TreeResource)
	tree.position = Vector2i(172, 481)
	tree.name = "Tree"
	add_child(tree)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# TODO: Remove at some point
func _unhandled_input(event: InputEvent) -> void:
	if not event.as_text().is_valid_int():
		return
	if not event.is_released():
		return
	if not is_instance_valid(entity):
		return
	
	if moving:
		entity.unset_target()
	
	moving = not moving
	
	match event.as_text():
		"0":
			# This should keep the entity in-place for a short time
			entity.set_target(entity.body)
		"1":
			print_debug(await entity.walk_to_and_pickup_random_resource())
		"2":
			print_debug(await entity.walk_to_and_use_random_resource_node())
		"3":
			print_debug(entity.pickup_random_nearby_resource())
		"4":
			print_debug(entity.use_random_nearby_resource_node())
		"5":
			# Switch entity
			var human1_entity: Entity = Game.get_entity_from_body($Human1 as CharacterBody2D)
			var human2_entity: Entity = Game.get_entity_from_body($Human2 as CharacterBody2D)
			
			entity = human1_entity if entity == human2_entity else human2_entity
		"6":
			# Turn a random resource to stone
			var resource_body: StaticBody2D = Game.get_random_resource()
			if not resource_body:
				print_debug("No resource found!")
				return
			
			var resource: NodeResource = Game.get_resource_from_body(resource_body)
			if resource.data == StoneResource:
				print_debug("That resource is already a stone!")
				return
			
			resource.data = StoneResource
