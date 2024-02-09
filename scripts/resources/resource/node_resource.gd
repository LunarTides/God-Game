class_name NodeResource
extends Node
## A base resource class which defines methods / members that applies to every inanimate resource.
## @experimental


## The StaticBody of the resource.
## The body should probably be the root of the resource.
@export var body: StaticBody2D

## The resource's sprite. This should probably be a sibling to the [WorldResource] node.
@export var sprite: Sprite2D

## The resource's collision node.
@export var collision_node: CollisionShape2D

## The resource's Area node.
@export var area: Area2D

## The resource's unique data.
var data: WorldResource:
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
