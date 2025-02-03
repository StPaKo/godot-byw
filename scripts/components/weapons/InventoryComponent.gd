extends Control
class_name InventoryComponent

var inventory = []
@export var inventory_size : int = 2
@export var column_amount : int = 2
@export var generator_location: int = 0
@export var receiver_location: int = 1
@onready var background : Panel = $Panel
@onready var container : GridContainer = $Panel/GridContainer
const inventory_slot_preload : PackedScene = preload("res://objects/ui/inventory/inventoryslot.tscn")
const slot_offset : int = 5
var dragged_slot : InventorySlot = null

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
	
	# remove later
	inventory[0] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/modifications/double_bullet 16x16.png")),
		"Double bullet",
		"Doubles the amount of fired bullets"
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
		slot.slot_dragged.connect(_on_slot_dragged)
		slot.slot_dropped.connect(_on_slot_dropped)
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

func _on_slot_dragged(slot: InventorySlot) -> void:
	dragged_slot = slot

func _on_slot_dropped() -> void:
	var drop_target : InventorySlot = get_slot_under_mouse()
	if drop_target and dragged_slot != drop_target:
		drop_slot(dragged_slot, drop_target)
	dragged_slot = null

func get_slot_under_mouse() -> InventorySlot:
	var mouse_position : Vector2 = get_global_mouse_position()
	for slot in container.get_children():
		var slot_rect = Rect2(slot.global_position, slot.size)
		if slot_rect.has_point(mouse_position):
			return slot
	return null

func get_slot_index(slot: InventorySlot) -> int:
	for i in range(container.get_child_count()):
		if container.get_child(i) == slot:
			return i
	return -1

func drop_slot(drag_slot: InventorySlot, drop_slot: InventorySlot) -> void:
	var drag_slot_idx : int = get_slot_index(drag_slot)
	var drop_slot_idx : int = get_slot_index(drop_slot)
	if drag_slot_idx < 0 or drag_slot_idx > inventory.size() or drop_slot_idx < 0 or drop_slot_idx > inventory.size():
		return
	if drop_slot.contained_modification["name"] in ["Generator", "Receiver"]:
		return
	var temp : Modification = inventory[drop_slot_idx]
	inventory[drop_slot_idx] = inventory[drag_slot_idx]
	inventory[drag_slot_idx] = temp
	_on_inventory_updated()
