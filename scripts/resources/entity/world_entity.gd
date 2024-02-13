class_name WorldEntity
extends Resource

## The entity's name.
@export var name: StringName

## The entity's texture.
@export var texture: Texture2D

## The entity's AI scene.
@export var ai: PackedScene

## The entity's health. Set this via the inspector in every entity scene to set the default amount for that entity.
@export var health: int

## How fast the entity moves. The formula is: [code]velocity = normalized_vector * 16 * speed * delta[/code].
@export var speed: int = 200

## The possible first names for each gender.
@export var possible_first_names: Dictionary = {
	"Male": [],
	"Female": [],
	"Non-binary": []
}

## The possible last names for the entity.
@export var possible_last_names: Array[String]

# CAUTION: Be careful of cancelations on xitter
## The possible genders for the entity.
@export var possible_genders: Array[String] = ["Male", "Female", "Non-binary"]

## The color of the sprite's modulate if the AI is controlling it.
@export var ai_color: Color = Color.WHITE

## The color of the sprite's modulate if the Player is controlling it.
@export var player_color: Color = Color.CRIMSON

## The color of the sprite's modulate if the Player is hovering their mouse over it.
@export var hover_color: Color = Color.YELLOW
