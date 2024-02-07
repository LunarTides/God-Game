class_name ResourceNode
extends Node
## A base resource node class which defines methods / members that applies to every resource node.
## @experimental


const ResourceScene: PackedScene = preload("res://scenes/resources/resource.tscn")

## The StaticBody of the resource node.
## The body should probably be the root of the resource node.
@export var body: StaticBody2D

## The resource node's sprite. This should probably be a sibling to the [ResourceNode] node.
@export var sprite: Sprite2D

## The resource node's collision node.
@export var collision_node: CollisionShape2D

## The resource node's Area node.
@export var area: Area2D

## The resource node's unique data.
var data: WorldResourceNode

var regenerating: bool = false

var _used_times: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.texture = data.texture
	collision_node.shape = data.collision_shape
	
	var area_collision_node: CollisionShape2D = CollisionShape2D.new()
	area_collision_node.shape = data.collision_shape
	area_collision_node.name = "CollisionShape2D"
	
	area.add_child(area_collision_node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite.texture = data.texture
	collision_node.shape = data.collision_shape
	
	area.get_node("CollisionShape2D").shape = data.collision_shape


## Sets up the resource node. You need to do this before using it.
func setup(resource_node: WorldResourceNode) -> void:
	data = resource_node


## Use the resource node.
func use() -> void:
	if regenerating or _used_times >= data.use_times:
		return
	
	_used_times += 1
	
	var resource: StaticBody2D = Game.create_resource(data.data)
	resource.global_position = Vector2(body.global_position.x + randf_range(-50.0, 50.0), body.global_position.y + randf_range(-50.0, 50.0))
	get_tree().root.add_child(resource)
	
	if _used_times >= data.use_times:
		_deplete()


func _deplete() -> void:
	if data.deplete_method == data.DepleteMethod.DESTROY:
		body.queue_free()
	elif data.deplete_method == data.DepleteMethod.DEPLETE_PERMANENT:
		pass
	elif data.deplete_method == data.DepleteMethod.DEPLETE_REGENERATE:
		regenerating = true
		_do_regenerate_cycle()


func _do_regenerate_cycle() -> void:
	if _used_times <= 0:
		regenerating = false
		return
	
	_used_times -= 1
	get_tree().create_timer(1, false).timeout.connect(_do_regenerate_cycle)
