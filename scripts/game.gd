extends Node


const EntityScene: PackedScene = preload("res://scenes/resources/entity.tscn")
const ResourceScene: PackedScene = preload("res://scenes/resources/resource.tscn")
const ResourceNodeScene: PackedScene = preload("res://scenes/resources/resource_node.tscn")

var entity_panel: Panel


#region entity functions
## Opens the entity panel for the specified entity. Pauses the game.
func open_entity_panel(entity: Entity) -> void:
	entity_panel.entity = entity
	entity_panel.open()


## Creates an entity with the specified data.
func create_entity(entity: WorldEntity) -> CharacterBody2D:
	var body: Node = EntityScene.instantiate()
	body.get_node("Data").data = entity
	return body


## Returns the [Entity] node from the entity's body.
func get_entity_from_body(body: CharacterBody2D) -> Entity:
	return body.get_node("Data") as Entity


## Returns a random entity in the scene.
## 
## [br][br][b]Note:[/b] Returns [code]null[/code] if no entity was found.
func get_random_entity() -> Entity:
	var body: CharacterBody2D = _get_random_node_in_group("Entities")
	if body == null:
		return null
	
	return get_entity_from_body(body)
#endregion


#region resource functions
## Creates a resource with the specified data.
func create_resource(resource: WorldResource) -> StaticBody2D:
	var body: Node = ResourceScene.instantiate()
	body.get_node("Data").data = resource
	return body


## Returns the [NodeResource] node from the resource's body.
func get_resource_from_body(body: StaticBody2D) -> NodeResource:
	return body.get_node("Data") as NodeResource


## Returns a random resource in the scene.
## 
## [br][br][b]Note:[/b] Returns [code]null[/code] if no resource was found.
func get_random_resource() -> NodeResource:
	var body: StaticBody2D = _get_random_node_in_group("Resources")
	if body == null:
		return null
	
	return get_resource_from_body(body)
#endregion


#region resource node functions
## Creates a resource node with the specified data.
func create_resource_node(resource_node: WorldResourceNode) -> StaticBody2D:
	var body: Node = ResourceNodeScene.instantiate()
	body.get_node("Data").data = resource_node
	return body


## Returns the [ResourceNode] node from the resource node's body.
func get_resource_node_from_body(body: StaticBody2D) -> ResourceNode:
	return body.get_node("Data") as ResourceNode


## Returns a random resource node in the scene.
## 
## [br][br][b]Note:[/b] Returns [code]null[/code] if no resource node was found.
func get_random_resource_node() -> ResourceNode:
	var body: StaticBody2D = _get_random_node_in_group("Resource Nodes")
	if body == null:
		return null
	
	return get_resource_node_from_body(body)
#endregion


## Returns the current viewport.
func viewport() -> Viewport:
	return get_viewport()


func _get_random_node_in_group(group: StringName) -> Node2D:
	var nodes: Array[Node] = get_tree().get_nodes_in_group(group)
	if nodes.size() == 0:
		return null
	
	return nodes.pick_random()
