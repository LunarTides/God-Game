extends Node

var entity_panel: Panel

func open_entity_panel(entity: Entity):
	entity_panel.entity = entity
	entity_panel.open()
