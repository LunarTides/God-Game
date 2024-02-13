class_name NodeResource
extends Node
## A base resource class which defines methods / members that applies to every inanimate resource.
## @experimental


## The StaticBody of the resource.
## The body should probably be the root of the resource.
@export var body: StaticBody2D

## The resource's sprite. This should probably be a sibling to the [WorldResource] node.
@export var sprite: Sprite2D

## The resource's unique data.
var data: WorldResource:
	set(new_data):
		data = new_data
		
		sprite.texture = data.texture
