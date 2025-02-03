extends Control
class_name InventoryComponent

var inventory = []
@export var inventory_size : int = 2
@export var column_amount : int = 2
@export var generator_location: int = 0
@export var receiver_location: int = 1
@onready var background = $Panel
@onready var container = $Panel/GridContainer
const inventory_slot_preload : PackedScene = preload("res://objects/ui/inventory/inventoryslot.tscn")
const slot_offset : int = 5

func _ready() -> void:
	inventory.resize(inventory_size)
	background.size = Vector2(column_amount, inventory_size / column_amount) * 64 + Vector2(column_amount + 1, inventory_size / column_amount + 1) * slot_offset
	container.position = Vector2(slot_offset, slot_offset)
	container.add_theme_constant_override("h_separation", slot_offset)
	container.add_theme_constant_override("v_separation", slot_offset)
	inventory[generator_location] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/modifications/generator 16x16.png")),
		"Generator",
		"Emits energy to power your weapon"
	)
	inventory[receiver_location] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/modifications/receiver 16x16.png")),
		"Receiver",
		"Consumes energy so your weapon can fire"
	)
	_on_inventory_updated()

func _process(delta: float) -> void:
	self.set_rotation(-self.get_parent().get_parent().rotation)
	if Input.is_action_just_pressed("toggle_inventory"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused

func add_modification(modification: Dictionary) -> void:
	_on_inventory_updated()

func remove_modification(idx: int) -> void:
	_on_inventory_updated()

func _on_inventory_updated() -> void:
	clear()
	container.columns = column_amount
	for item in self.inventory:
		var slot = inventory_slot_preload.instantiate()
		container.add_child(slot)
		if item != null:
			slot.set_modification(item.get_item())
		else:
			slot.clear()

func clear() -> void:
	while container.get_child_count() > 0:
		var child = container.get_child(0)
		container.remove_child(child)
		child.queue_free()
