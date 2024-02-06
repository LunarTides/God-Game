class_name Entity
extends Node
## A base entity class which defines methods / members that applies to every living entity.
## @experimental


## Emitted when the entity is damaged.
signal damaged(amount: int)

## Emitted when the entity dies.
signal killed

## Emitted when the entity reaches its target.
signal target_reached(position: Vector2)


## The CharacterBody of the entity. This will be the thing that moves.
## The CharacterBody should probably be the root of the entity.
@export var body: CharacterBody2D

## The entity's sprite. This should probably be a sibling to the [Entity] node.
@export var sprite: Sprite2D

## The entity's collision node.
@export var collision_node: CollisionShape2D

## The entity's Area node. This is currently only used for hover detection, so define the collision shape correctly.
@export var area: Area2D

## Whether or not the player is controlling this entity. If so, it disables the AI.
@export var is_controlling := false

## How close the entity has to get to its target position before reaching it.
## This is to prevent jittering once it reaches its target.
@export var target_threshold := 5.0

var data: WorldEntity:
	set(new_data):
		data = new_data
		
		sprite.texture = data.texture
		collision_node.shape = data.collision_shape
		if is_instance_valid(ai):
			remove_child(ai)
		
		# AI
		var ai_node = data.ai.instantiate()
		ai_node.entity = self
		ai_node.pass_entity()
		walk_to_position = ai_node.walk_to_position
		ai = ai_node.get_child(0) as BeehaveTree
		ai.name = "AI"
		ai.actor = body
		add_sibling(ai)
		
		# Area Collision
		var area_collision_node := CollisionShape2D.new()
		area_collision_node.shape = data.collision_shape
		area_collision_node.name = "CollisionShape2D"
		
		area.add_child(area_collision_node)
		
		generate_gender()
		generate_name()

## The entity's gender.
var gender := "None"

## The abbreviated version of the entity's gender.
var abv_gender: String:
	get:
		if gender == "Non-binary":
			return "Enby"
		
		return gender[0]
	set(_value):
		return

## The entity's name.
var entity_name := "Placeholder"

## The entity's inventory.
## This looks something like this: [code]{"Resource Name": [WorldResource:<Node#30232544541>, WorldResource:<Node#59275306838>][/code].
var inventory: Dictionary

## The entity's AI tree node. This will define the AI's behaviour.
var ai: BeehaveTree

## The WalkToPosition AI node. Every entity should have this node in the AI tree,
## since every entity should be able to move.
var walk_to_position: WalkToPosition

var _has_reached_target = false

## The entity's health.
@onready var health = data.health


func _ready():
	area.mouse_entered.connect(_hover)
	area.mouse_exited.connect(_stop_hover)
	
	area.input_event.connect(_on_area_input_event)
	
	# This isn't required, but we should still probably do this
	ai._ready()


func _physics_process(delta):
	# For some reason, when having the ai in its own scene, we need to manually process it here
	ai._process_internally()
	
	if Input.is_action_just_pressed("release_control"):
		is_controlling = false
		sprite.modulate = data.ai_color
	
	if is_controlling:
		# Control the entity
		body.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	body.velocity = body.velocity.normalized() * 16 * data.speed * delta
	
	if walk_to_position.position and not is_controlling:
		if body.position.distance_to(walk_to_position.position) > target_threshold:
			body.move_and_slide()
	else:
		body.move_and_slide()


## Deal damage to the entity.
func damage(amount: int):
	health -= amount
	
	damaged.emit(amount)
	
	if health <= 0:
		killed.emit()
		body.queue_free()


## Toggle control over the entity.
func toggle_control():
	is_controlling = not is_controlling
	_reset_modulate()


## Begins moving the entity towards the target node.
func set_target(target: Node2D):
	walk_to_position.position = target.global_position
	_has_reached_target = false


## Begins moving the entity towards the target position.
func set_target_position(position: Vector2):
	walk_to_position.position = position
	_has_reached_target = false


## Unsets the target. The AI will resume its normal operations.
func unset_target():
	walk_to_position.position = Vector2.ZERO
	_has_reached_target = false


## Returns if the specified position is the entity's target.
func target_is_vector(position: Vector2):
	return walk_to_position.position == position


## Returns if the specified node is the entity's target.
func target_is_node(node: Node2D):
	return walk_to_position.position == node.global_position


## Returns if the entity has a target.
## As long as an AI is controlling the entity, this will almost always return true.
func has_target():
	return walk_to_position.position != null


## This will emit the target_reached signal if it hasn't been emitted for that target before.
func emit_target_reached(position: Vector2):
	if not _has_reached_target:
		_has_reached_target = true
		target_reached.emit(position)


## Picks up the specified resource. The resource needs to be right next to the entity for this to work.
## Returns if the pickup was successful.
# TODO: Add ability for players to do this
func pickup_resource(resource: NodeResource) -> bool:
	# Check if the resource is in a certain radius around the entity
	# TODO: Don't hardcode the distance value
	if body.position.distance_to(resource.body.global_position) > 5:
		return false
	
	var resource_name = resource.data.name
	
	if not inventory.has(resource_name):
		inventory[resource_name] = []
	
	if not is_instance_valid(resource) or resource in inventory[resource.data.name]:
		return false
	
	inventory[resource_name].append(resource)
	
	resource.body.queue_free()
	
	print_debug(inventory)
	return true


## Picks up a random resource from around the entity. The resource needs to be right next to the entity for this to work.
## Returns if the pickup was successful.
# TODO: Make this return bool
func pickup_random_resource(resource: NodeResource):
	assert(false, "Not implemented")


## Walks to the specified resource, then picks it up.
## Returns if the pickup was successful.
func walk_to_and_pickup_resource(resource: NodeResource) -> bool:
	set_target(resource.body)
	await target_reached
	return pickup_resource(resource)


## Walks to and picks up a random resource.
## Returns if the pickup was successful.
# TODO: Make this return bool
func walk_to_and_pickup_random_resource():
	assert(false, "Not implemented")


## Uses the specified resource node. The resource node needs to be right next to the entity for this to work.
## Returns if the usage was successful.
func use_resource_node(resource_node: ResourceNode) -> bool:
	# Check if the resource node is in a certain radius around the entity
	if body.position.distance_to(resource_node.body.global_position) > 5:
		return false
	
	resource_node.use()
	return true


## Walks to the specified resource node, then uses it up.
## Returns if the usage was successful.
func walk_to_and_use_resource_node(resource_node: ResourceNode) -> bool:
	set_target(resource_node.body)
	await target_reached
	
	# Use up the resource node
	var result = true
	
	var i = 0
	
	# Use `i` as a backup incase something goes wrong
	# TODO: Don't use _used_times here
	while resource_node._used_times < resource_node.data.use_times and i < resource_node.data.use_times:
		await get_tree().create_timer(1, false).timeout
		
		result = result and use_resource_node(resource_node)
		i += 1
	
	return result


## Randomize and set the entity's gender.
func generate_gender():
	gender = data.possible_genders.pick_random()


## Generates a random first name, and last name and gives them to the entity.
## The first name depends on the gender, and the pool is [member possible_first_names] and [member possible_last_names].
func generate_name():
	entity_name = "%s %s" % [data.possible_first_names[gender].pick_random(), data.possible_last_names.pick_random()]


func _hover():
	sprite.modulate = data.hover_color


func _stop_hover():
	_reset_modulate()


func _reset_modulate():
	sprite.modulate = data.ai_color if not is_controlling else data.player_color


func _click():
	Game.open_entity_panel(self)


func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("left_click"):
		_click()