class_name WorldResourceNode
extends Resource

## The resource that the resource node drops.
@export var data: WorldResource

## The name of the resource node.
@export var name: StringName

## The texture of the resource node.
@export var texture: Texture2D

## The collision shape of the resource node.
@export var collision_shape: Shape2D

## The amount of times the resource node can be used.
@export var use_times: int

# TODO: Add `deplete_method` which can be: `DESTROY`, `DEPLETE_PERMANENT`, `DEPLETE_REGENERATE`
