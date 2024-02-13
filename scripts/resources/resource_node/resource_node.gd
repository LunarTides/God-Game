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

## The resource node's unique data. Set this before
var data: WorldResourceNode:
	set(new_data):
		data = new_data
		
		sprite.texture = data.texture
		collision_node.shape = data.collision_shape
		
		if area.has_node("CollisionShape2D"):
			area.get_node("CollisionShape2D").shape = data.collision_shape
		else:
			var area_collision_node: CollisionShape2D = CollisionShape2D.new()
			area_collision_node.shape = data.collision_shape
			area_collision_node.name = "CollisionShape2D"
			
			area.add_child(area_collision_node)

## Whether or not the resource node is regenerating. Only works if [member data.deplete_method] is [enum DEPLETE_REGENERATE]
var is_regenerating: bool = false

## Whether or not the resource node is depleted.
var is_depleted: bool:
	get:
		return _used_times >= data.use_times
	set(_new_depleted):
		assert(false, "Don't set `is_depleted`")

var _used_times: int = 0


## Use the resource node.
func use() -> void:
	if is_regenerating or is_depleted:
		return
	
	_used_times += 1
	
	var resource: StaticBody2D = Game.create_resource(data.resource)
	resource.global_position = Vector2(body.global_position.x + randf_range(-50.0, 50.0), body.global_position.y + randf_range(-50.0, 50.0))
	get_tree().root.add_child(resource)
	
	if is_depleted:
		_deplete()


func _deplete() -> void:
	if data.deplete_method == data.DepleteMethod.DESTROY:
		body.queue_free()
	elif data.deplete_method == data.DepleteMethod.DEPLETE_PERMANENT:
		pass
	elif data.deplete_method == data.DepleteMethod.DEPLETE_REGENERATE:
		is_regenerating = true
		get_tree().create_timer(1, false).timeout.connect(_do_regenerate_cycle)


func _do_regenerate_cycle() -> void:
	if _used_times <= 0:
		is_regenerating = false
		return
	
	_used_times -= 1
	get_tree().create_timer(1, false).timeout.connect(_do_regenerate_cycle)
