class_name WorldResourceNode
extends Resource

## The name of the resource node.
@export var name: StringName

## The texture of the resource node.
@export var texture: Texture2D

## The collision shape of the resource node.
@export var collision_shape: Shape2D

## The amount of times the resource node can be used.
@export var use_times: int

## The resource that the resource node drops.
@export var resource: WorldResource

## What to do when the resource node is depleted.
@export var deplete_method: DepleteMethod = DepleteMethod.DESTROY

enum DepleteMethod {
	## Destroy the resource node.
	DESTROY,
	## Prevent the resource node from ever being used again.
	DEPLETE_PERMANENT,
	## The resource node will start healing. It takes [member use_times] seconds to fully regenerate.
	DEPLETE_REGENERATE,
}
