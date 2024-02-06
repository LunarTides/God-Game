extends Node


const EntityScene := preload("res://scenes/resources/entity.tscn")
const ResourceScene := preload("res://scenes/resources/resource.tscn")
const ResourceNodeScene := preload("res://scenes/resources/resource_node.tscn")

var entity_panel: Panel


## Opens the entity panel for the specified entity. Pauses the game.
func open_entity_panel(entity: Entity):
	entity_panel.entity = entity
	entity_panel.open()


## Creates an entity with the specified data.
func create_entity(entity: WorldEntity) -> CharacterBody2D:
	var body = EntityScene.instantiate()
	body.get_node("Data").data = entity
	return body


## Creates a resource with the specified data.
func create_resource(resource: WorldResource) -> StaticBody2D:
	var body = ResourceScene.instantiate()
	body.get_node("Data").data = resource
	return body


## Creates a resource node with the specified data.
func create_resource_node(resource_node: WorldResourceNode) -> StaticBody2D:
	var body = ResourceNodeScene.instantiate()
	body.get_node("Data").data = resource_node
	return body


func viewport() -> Viewport:
	return get_viewport()
