extends Node
class_name ResourceNode
## A base resource node class which defines methods / members that applies to every resource node.
## @experimental


## The StaticBody of the resource node.
## The body should probably be the root of the resource node.
@export var body: StaticBody2D

## The resource node's sprite. This should probably be a sibling to the [ResourceNode] node.
@export var sprite: Sprite2D

## The resource node's Area node.
@export var area: Area2D

## The resource node's name.
@export var resource_node_name: StringName

## How many times the resource node can be used before breaking
@export var use_times: int

## The resource that the resource node drops
var resource: WorldResource

var _used_times = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


## Sets up the resource node. You need to do this before using it.
func setup(resource: WorldResource):
	self.resource = resource


## Use the resource node.
func use():
	_used_times += 1
	
	var ResourceScene = load("res://scenes/resources/%s.tscn" % resource.resource_name.to_lower().replace(" ", "_"))
	
	var resource_body: StaticBody2D = ResourceScene.instantiate()
	resource_body.global_position = Vector2(body.global_position.x + randf_range(-50.0, 50.0), body.global_position.y + randf_range(-50.0, 50.0))
	get_tree().root.add_child(resource_body)
	
	if _used_times >= use_times:
		body.queue_free()
