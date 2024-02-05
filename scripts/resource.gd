extends Node
class_name WorldResource
## A base resource class which defines methods / members that applies to every inanimate resource.
## @experimental

## The StaticBody of the resource.
## The body should probably be the root of the resource.
@export var body: StaticBody2D

## The resource's sprite. This should probably be a sibling to the [WorldResource] node.
@export var sprite: Sprite2D

## The resource's Area node.
@export var area: Area2D

## The resource's name.
@export var resource_name: StringName

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
