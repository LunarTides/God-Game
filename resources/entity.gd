extends Node
class_name Entity

signal damaged(amount: int)
signal killed

@export var character: CharacterBody2D
@export var sprite: Sprite2D
@export var ai: BeehaveTree
@export var area: Area2D

@export var walk_to_node: WalkToNode

@export var health: int
@export var speed: int = 1
@export var is_controlling: bool = false

@export var possible_first_names: Dictionary = {
	"Male": [],
	"Female": [],
	"Non-binary": []
}
@export var possible_last_names: Array[String]

# CAUTION: Be careful of cancelations on xitter
@export var possible_genders: Array[String] = ["Male", "Female", "Non-binary"]

@export var ai_color := Color.WHITE
@export var player_color := Color.CRIMSON
@export var hover_color := Color.YELLOW

var gender = "None"
var abv_gender: String:
	get:
		if gender == "Non-binary":
			return "Enby"
		
		return gender[0]
	set(_value):
		return

var entity_name := "Placeholder"
var target_position: Vector2
@export var target_treshold: float = 5

func _ready():
	generate_gender()
	generate_name()
	
	area.mouse_entered.connect(hover)
	area.mouse_exited.connect(stop_hover)
	
	area.input_event.connect(_on_area_input_event)

func _physics_process(delta):
	if Input.is_action_just_pressed("release_control"):
		is_controlling = false
		sprite.modulate = ai_color
	
	if is_controlling:
		# Control the entity
		ai.disable()
		ai.interrupt()
		
		character.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	else:
		# Make the ai control the entity
		ai.enable()
	
	character.velocity = character.velocity.normalized() * 16 * speed * delta
	
	if target_position:
		if character.position.distance_to(target_position) > target_treshold:
			character.move_and_slide()
	else:
		character.move_and_slide()
	
	character.velocity = Vector2.ZERO

func _on_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("left_click"):
		click()

func hover():
	sprite.modulate = hover_color

func stop_hover():
	reset_modulate()

func click():
	Game.open_entity_panel(self)

func damage(amount: int):
	health -= amount
	
	damaged.emit(amount)
	
	if health <= 0:
		killed.emit()
		character.queue_free()

func toggle_control():
	is_controlling = not is_controlling
	reset_modulate()

func set_target(_target: Node2D):
	walk_to_node.node = _target
	target_position = _target.global_position

func unset_target():
	walk_to_node.node = null
	target_position = Vector2.ZERO

func has_target():
	return walk_to_node.node != null

func generate_gender():
	gender = possible_genders.pick_random()

func generate_name():
	entity_name = "%s %s" % [possible_first_names[gender].pick_random(), possible_last_names.pick_random()]

func reset_modulate():
	sprite.modulate = ai_color if not is_controlling else player_color
