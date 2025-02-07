extends Node2D
class_name Modification

@export var icon_texture : Texture
@export var item_name : String 
@export var item_description : String
@onready var icon_sprite : Sprite2D = $Icon
const scene_path : String = "res://objects/modifications/modification.tscn"
var power_direction : Vector2i
var is_powered: bool

func _init(icon: Texture = null, modification_name: String = "", description: String = "", direction: Vector2 = Vector2(0, 0)) -> void:
	self.icon_texture = icon
	self.item_name = modification_name
	self.item_description = description
	self.power_direction = round(direction.normalized())

func power_off() -> void:
	is_powered = false
	self.power_direction = Vector2(0, 0)

func power_on(direction: Vector2i, rotate: int) -> void:
	is_powered = true
	match rotate:
		0:
			self.power_direction = direction
		1:
			self.power_direction = Vector2(direction.y, direction.x)
		2:
			self.power_direction = Vector2(-direction.y, -direction.x)

func get_item() -> Dictionary:
	var item = {
		"texture": self.icon_texture,
		"name": self.item_name,
		"description": self.item_description,
		"direction": self.power_direction,
		"powered": self.is_powered,
	}
	return item
