extends Node2D


const HumanResource: WorldEntity = preload("res://resources/entities/human.tres")
const TreapleResource: WorldEntity = preload("res://resources/entities/treaple.tres")

const WoodResource: WorldResource = preload("res://resources/resources/wood.tres")
const StoneResource: WorldResource = preload("res://resources/resources/stone.tres")

const TreeResource: WorldResourceNode = preload("res://resources/resource_nodes/tree.tres")
const BoulderResource: WorldResourceNode = preload("res://resources/resource_nodes/boulder.tres")

@export var entity_panel: Panel

# TODO: Remove at some point
@export var human_spawn_1: Node2D
@export var human_spawn_2: Node2D
@export var wood_spawn: Node2D
@export var tree_spawn: Node2D

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
	wood.position = wood_spawn.position
	wood.name = "Wood"
	add_child(wood)
	
	# Tree
	var tree: StaticBody2D = Game.create_resource_node(TreeResource)
	tree.position = tree_spawn.position
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
	
	match event.as_text():
		"0":
			entity.unset_target()
		"1":
			entity.walk_to_and_pickup_random_resource()
		"2":
			entity.walk_to_and_use_random_resource_node()
		"3":
			entity.pickup_random_nearby_resource()
		"4":
			entity.use_random_nearby_resource_node()
		"5":
			# Switch entity
			var new_entity: Entity
			
			for i: int in range(20):
				new_entity = Game.get_random_entity()
				
				if new_entity != entity:
					break
				
			entity = new_entity
		"6":
			# Turn a random resource to stone
			var resource: NodeResource = Game.get_random_resource()
			if not resource:
				print_debug("No resource found!")
				return
			
			if resource.data == StoneResource:
				resource.data = WoodResource
			else:
				resource.data = StoneResource
		"7":
			# Turn a random resource node to stone
			var resource_node: ResourceNode = Game.get_random_resource_node()
			if not resource_node:
				print_debug("No resource node found!")
				return
			
			if resource_node.data == TreeResource:
				resource_node.data = BoulderResource
			else:
				resource_node.data = TreeResource
		"8":
			# Turn a random entity to treaple
			var entity: Entity = Game.get_random_entity()
			if not entity:
				print_debug("No entity found!")
				return
			
			if entity.data == HumanResource:
				entity.data = TreapleResource
			else:
				entity.data = HumanResource
		"9":
			entity.set_target(entity.body)
