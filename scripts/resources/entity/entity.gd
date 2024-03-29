class_name Entity
extends Node
## A base entity class which defines methods / members that applies to every living entity.
## @experimental

#region signals
## Emitted when the entity is damaged.
signal damaged(amount: int)

## Emitted when the entity dies.
signal killed

## Emitted when the entity reaches its target.
signal target_reached(position: Vector2)

## Emitted when the entity switches its target.
signal target_switched(position: Vector2)
#endregion

#region exported variables
## The CharacterBody of the entity. This will be the thing that moves.
## The CharacterBody should probably be the root of the entity.
@export var body: CharacterBody2D

## The entity's sprite. This should probably be a sibling to the [Entity] node.
@export var sprite: Sprite2D

## The entity's Area node. This is currently only used for hover detection, so define the collision shape correctly.
@export var area: Area2D

## Whether or not the player is controlling this entity. If so, it disables the AI.
@export var is_controlling: bool = false

## How close the entity has to get to its target position before reaching it.
## This is to prevent jittering once it reaches its target.
@export var target_threshold: float = 5.0

## The reach that the entity has. The entity can only pick up/use resources/resource nodes within this reach.
@export var reach: float = 5.0
#endregion

#region public variables
var data: WorldEntity:
	set(new_data):
		if data:
			# Change max health while keeping damage
			health = new_data.health - (data.health - health)
		
		data = new_data
		
		sprite.texture = data.texture
		if is_instance_valid(ai):
			remove_child(ai)
		
		# AI
		var ai_node: Node = data.ai.instantiate()
		ai_node.entity = self
		ai_node.pass_entity()
		walk_to_position = ai_node.walk_to_position
		ai = ai_node.get_child(0) as BeehaveTree
		ai.name = "AI"
		ai.actor = body
		
		if is_inside_tree():
			ai.reparent(self)
		
		generate_gender()
		generate_name()

## The entity's gender.
var gender: String = "None"

## The abbreviated version of the entity's gender.
var abv_gender: String:
	get:
		if gender == "Non-binary":
			return "Enby"
		
		return gender[0]
	set(_value):
		return

## The entity's name.
var entity_name: String = "Placeholder"

## The entity's inventory.
## This looks something like this: [code]{"Resource Name": [WorldResource:<Node#30232544541>, WorldResource:<Node#59275306838>][/code].
var inventory: Dictionary

## The entity's AI tree node. This will define the AI's behaviour.
var ai: BeehaveTree

## The WalkToPosition AI node. Every entity should have this node in the AI tree,
## since every entity should be able to move.
var walk_to_position: WalkToPosition
#endregion

#region private variables
var _has_reached_target: bool = false
var _is_walking_to_resource_node: bool = false
#endregion

#region onready variables
## The entity's health.
@onready var health: int = data.health
#endregion


#region override functions
func _ready() -> void:
	area.mouse_entered.connect(_hover)
	area.mouse_exited.connect(_stop_hover)
	
	area.input_event.connect(_on_area_input_event)
	ai.reparent(self)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("release_control"):
		is_controlling = false
		sprite.modulate = data.ai_color
	
	if is_controlling:
		# Control the entity
		body.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
		if Input.is_action_just_pressed("pickup"):
			pickup_random_nearby_resource()
		elif Input.is_action_just_pressed("harvest"):
			use_random_nearby_resource_node()
	
	body.velocity = body.velocity.normalized() * 16 * data.speed * delta
	
	if is_instance_valid(walk_to_position) and walk_to_position.position and not is_controlling:
		if body.position.distance_to(walk_to_position.position) > target_threshold:
			body.move_and_slide()
	else:
		body.move_and_slide()
#endregion


#region public functions
#region general functions
## Deal damage to the entity.
func damage(amount: int) -> void:
	health -= amount
	
	damaged.emit(amount)
	
	if health <= 0:
		killed.emit()
		body.queue_free()


## Toggle control over the entity.
func toggle_control() -> void:
	is_controlling = not is_controlling
	_reset_modulate()


## Randomize and set the entity's gender.
func generate_gender() -> void:
	gender = data.possible_genders.pick_random()


## Generates a random first name, and last name and gives them to the entity.
## The first name depends on the gender, and the pool is [member possible_first_names] and [member possible_last_names].
func generate_name() -> void:
	entity_name = "%s %s" % [data.possible_first_names[gender].pick_random(), data.possible_last_names.pick_random()]
#endregion


#region target functions
## Begins moving the entity towards the target node.
func set_target(target: Node2D) -> void:
	set_target_position(target.global_position)


## Unsets the target. The AI will resume its normal operations.
func unset_target() -> void:
	set_target_position(Vector2.ZERO)


## Begins moving the entity towards the target position.
func set_target_position(position: Vector2) -> void:
	if not is_instance_valid(walk_to_position):
		return
	
	walk_to_position.position = position
	_has_reached_target = false
	target_switched.emit(position)


## Returns if the specified position is the entity's target.
func target_is_vector(position: Vector2) -> bool:
	if not is_instance_valid(walk_to_position):
		return false
	
	return walk_to_position.position == position


## Returns if the specified node is the entity's target.
func target_is_node(node: Node2D) -> bool:
	if not is_instance_valid(walk_to_position):
		return false
	
	return walk_to_position.position == node.global_position


## Returns if the entity has a target.
## As long as an AI is controlling the entity, this will almost always return true.
func has_target() -> bool:
	if not is_instance_valid(walk_to_position):
		return false
	
	return walk_to_position.position != null


## This will emit the target_reached signal if it hasn't been emitted for that target before.
func emit_target_reached(position: Vector2) -> void:
	if not _has_reached_target:
		_has_reached_target = true
		target_reached.emit(position)
#endregion


#region resource functions
## Picks up the specified resource. The resource needs to be right next to the entity for this to work.
## Returns if the pickup was successful.
func pickup_resource(resource: NodeResource) -> bool:
	# Check if the resource is in a certain radius around the entity
	if not _is_node_in_range(resource.body) or resource.body.is_queued_for_deletion():
		return false
	
	var resource_name: StringName = resource.data.name
	
	if not inventory.has(resource_name):
		inventory[resource_name] = []
	
	if not is_instance_valid(resource) or resource in inventory[resource.data.name]:
		return false
	
	inventory[resource_name].append(resource.data)
	
	resource.body.queue_free()
	return true


## Picks up a random resource from around the entity. The resource needs to be right next to the entity for this to work.
## Returns if the pickup was successful.
func pickup_random_nearby_resource() -> bool:
	var resource: NodeResource = get_random_nearby_resource()
	if not resource:
		return false
	
	pickup_resource(resource)
	return true


## Walks to the specified resource, then picks it up.
## Returns if the pickup was successful.
func walk_to_and_pickup_resource(resource: NodeResource) -> bool:
	set_target(resource.body)
	await target_reached
	
	if is_controlling:
		unset_target()
		return false
	
	return pickup_resource(resource)


## Walks to and picks up a random resource.
## Returns if the pickup was successful.
func walk_to_and_pickup_random_resource() -> bool:
	var resource: NodeResource = Game.get_random_resource()
	if not resource:
		return false
	
	await walk_to_and_pickup_resource(resource)
	return true


## Returns a random resource that is in range of the entity.
## 
## [br][br][b]Note:[/b] Returns [code]null[/code] if no valid resource was found.
func get_random_nearby_resource() -> NodeResource:
	var resource_body: StaticBody2D = _get_random_nearby_node_in_group("Resources")
	if resource_body == null:
		return null
	
	return Game.get_resource_from_body(resource_body)
#endregion


#region resource node functions
## Uses the specified resource node. The resource node needs to be right next to the entity for this to work.
## Returns if the usage was successful.
func use_resource_node(resource_node: ResourceNode) -> bool:
	# Check if the resource node is in a certain radius around the entity
	if not _is_node_in_range(resource_node.body):
		return false
	
	resource_node.use()
	return true


## Uses a random resource node from around the entity. The resource node needs to be right next to the entity for this to work.
## Returns if the use was successful.
func use_random_nearby_resource_node() -> bool:
	var resource_node: ResourceNode = get_random_nearby_resource_node()
	if not resource_node:
		return false
	
	use_resource_node(resource_node)
	return true


## Walks to the specified resource node, then uses it up.
## Returns if the usage was successful.
func walk_to_and_use_resource_node(resource_node: ResourceNode) -> bool:
	set_target(resource_node.body)
	
	# If the entity is already walking towards the resource node, stop.
	# This is so it doesn't stack and use up the resource node in 1 second.
	if _is_walking_to_resource_node:
		return false
	
	_is_walking_to_resource_node = true
	
	await target_reached
	
	# If the player is controlling the entity by the time it reaches the resource node, stop.
	if is_controlling:
		unset_target()
		return false
	
	# Use up the resource node
	var result: bool = true
	var i: int = 0
	
	# Use `i` as a backup incase something goes wrong
	while not resource_node.is_depleted and i < resource_node.data.use_times:
		await get_tree().create_timer(1, false).timeout
		if not is_instance_valid(resource_node):
			result = false
			break
		
		result = result and use_resource_node(resource_node)
		i += 1
	
	_is_walking_to_resource_node = false
	
	return result


## Walks to and uses up a random resource node.
## Returns if the use was successful.
func walk_to_and_use_random_resource_node() -> bool:
	var resource_node: ResourceNode = Game.get_random_resource_node()
	if not resource_node:
		return false
	
	await walk_to_and_use_resource_node(resource_node)
	return true


## Returns a random resource node that is in range of the entity.
## 
## [br][br][b]Note:[/b] Returns [code]null[/code] if no valid resource node was found.
func get_random_nearby_resource_node() -> ResourceNode:
	var resource_node_body: StaticBody2D = _get_random_nearby_node_in_group("Resource Nodes")
	if resource_node_body == null:
		return null
	
	return Game.get_resource_node_from_body(resource_node_body)
#endregion
#endregion


#region private functions
func _hover() -> void:
	sprite.modulate = data.hover_color


func _stop_hover() -> void:
	_reset_modulate()


func _reset_modulate() -> void:
	sprite.modulate = data.ai_color if not is_controlling else data.player_color


func _is_node_in_range(node: Node2D) -> bool:
	# If the player is controlling the entity, 10x its reach
	var entity_range: float = reach if not is_controlling else reach * 10
	
	return body.position.distance_to(node.global_position) <= entity_range


func _get_random_nearby_node_in_group(group: StringName) -> Node2D:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(group).filter(_is_node_in_range)
	if nodes.size() == 0:
		return null
	
	return nodes.pick_random()


func _click() -> void:
	Game.open_entity_panel(self)


func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("left_click"):
		_click()
#endregion
