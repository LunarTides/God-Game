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

## The entity's AI tree node. This will define the AI's behaviour.
@export var ai: BeehaveTree

## The entity's Area node. This is currently only used for hover detection, so define the collision shape correctly.
@export var area: Area2D

## The WalkToPosition AI node. Every entity should have this node in the AI tree,
## since every entity should be able to move.
@export var walk_to_position: WalkToPosition

## The entity's health. Set this via the inspector in every entity scene to set the default amount for that entity.
@export var health: int

## How fast the entity moves. The formula is: [code]velocity = normalized_vector * 16 * speed * delta[/code]
@export var speed: int = 200

## Whether or not the player is controlling this entity. If so, it disables the AI.
@export var is_controlling := false

## The possible first names for each gender.
@export var possible_first_names := {
	"Male": [],
	"Female": [],
	"Non-binary": []
}

## The possible last names for the entity.
@export var possible_last_names: Array[String]

# CAUTION: Be careful of cancelations on xitter
## The possible genders for the entity.
@export var possible_genders := ["Male", "Female", "Non-binary"]

## The color of the sprite's modulate if the AI is controlling it.
@export var ai_color := Color.WHITE

## The color of the sprite's modulate if the Player is controlling it.
@export var player_color := Color.CRIMSON

## The color of the sprite's modulate if the Player is hovering their mouse over it.
@export var hover_color := Color.YELLOW

## How close the entity has to get to its target position before reaching it.
## This is to prevent jittering once it reaches its target.
@export var target_threshold := 5.0

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
## This looks something like this: [code]{"Resource Name": [WorldResource:<Node#30232544541>, WorldResource:<Node#59275306838>][/code]
var inventory: Dictionary


var _has_reached_target = false


func _ready():
	generate_gender()
	generate_name()
	
	area.mouse_entered.connect(_hover)
	area.mouse_exited.connect(_stop_hover)
	
	area.input_event.connect(_on_area_input_event)


func _physics_process(delta):
	if Input.is_action_just_pressed("release_control"):
		is_controlling = false
		sprite.modulate = ai_color
	
	if is_controlling:
		# Control the entity
		body.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	body.velocity = body.velocity.normalized() * 16 * speed * delta
	
	if walk_to_position.position and not is_controlling:
		if body.position.distance_to(walk_to_position.position) > target_threshold:
			body.move_and_slide()
	else:
		body.move_and_slide()


## Deal damage to the entity
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
func pickup_resource(resource: WorldResource) -> bool:
	# Check if the resource is in a certain radius around the entity
	if body.position.distance_to(resource.body.global_position) > 5:
		return false
	
	if not inventory.has(resource.resource_name):
		inventory[resource.resource_name] = []
	
	inventory[resource.resource_name].append(resource)
	
	resource.body.queue_free()
	
	print_debug(inventory)
	return true


## Walks to the specified resource, then picks it up.
## Returns if the pickup was successful
func walk_to_and_pickup_resource(resource: WorldResource) -> bool:
	set_target(resource.body)
	await target_reached
	return pickup_resource(resource)


## Randomize and set the entity's gender.
func generate_gender():
	gender = possible_genders.pick_random()


## Generates a random first name, and last name and gives them to the entity.
## The first name depends on the gender, and the pool is [member possible_first_names] and [member possible_last_names].
func generate_name():
	entity_name = "%s %s" % [possible_first_names[gender].pick_random(), possible_last_names.pick_random()]


func _hover():
	sprite.modulate = hover_color


func _stop_hover():
	_reset_modulate()


func _reset_modulate():
	sprite.modulate = ai_color if not is_controlling else player_color


func _click():
	Game.open_entity_panel(self)


func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("left_click"):
		_click()
