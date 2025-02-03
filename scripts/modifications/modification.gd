@tool
extends Node2D
class_name Modification

@export var icon_texture : Texture
@export var item_name : String 
@export var item_description : String
@onready var icon_sprite : Sprite2D = $Icon
const scene_path : String = "res://objects/modifications/modification.tscn"

func _init(icon: Texture = null, modification_name: String = "", description: String = "") -> void:
	self.icon_texture = icon
	self.item_name = modification_name
	self.item_description = description

func _ready() -> void:
	if not Engine.is_editor_hint():
		icon_sprite.texture = icon_texture

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		icon_sprite.texture = icon_texture

func get_item() -> Dictionary:
	var item = {
		"texture": icon_texture,
		"name": item_name,
		"description": item_description
	}
	return item
