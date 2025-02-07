extends Control
class_name InventoryComponent

var inventory = []
@export var inventory_owner : RayCast2D
@export var inventory_size : int = 2
@export var column_amount : int = 2
@export var generator_dictionary : Dictionary = { "position": 0, "direction": Vector2i(0, 0) }
@export var receiver_position : int = 0
@export var space_positions : Array[int]
@onready var background : Panel = $Panel
@onready var container : GridContainer = $Panel/GridContainer
const inventory_slot_preload : PackedScene = preload("res://objects/ui/inventory/inventoryslot.tscn")
const slot_offset : int = 5
var dragged_slot : InventorySlot = null
var is_receiver_powered : bool = false
var modification_data : Array

func _ready() -> void:
	var json : JSON = JSON.new()
	if json.parse(FileAccess.get_file_as_string("res://scripts/modifications/modification_list.json")) == OK:
		if typeof(json.data) == TYPE_ARRAY:
			modification_data = json.data
		else:
			print("JSON read error: Unexpected data")
	else:
		print("JSON parse error: ", json.get_error_message(), " at line ", json.get_error_line())
	inventory.resize(inventory_size)
	for i in range(inventory.size()):
		if i in self.space_positions:
			inventory[i] = null
		else:
			inventory[i] = Modification.new()
	inventory[generator_dictionary["position"]] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file(self.modification_data[0]["texture_path"])),
		self.modification_data[0]["name"],
		self.modification_data[0]["description"],
		generator_dictionary["direction"]
	)
	inventory[generator_dictionary["position"]].power_on(generator_dictionary["direction"], 0)
	inventory[receiver_position] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file(self.modification_data[1]["texture_path"])),
		self.modification_data[1]["name"],
		self.modification_data[1]["description"]
	)
	inventory[1] = Modification.new(
		ImageTexture.create_from_image(Image.load_from_file(self.modification_data[2]["texture_path"])),
		self.modification_data[2]["name"],
		self.modification_data[2]["description"]
	)
	background.size = Vector2(column_amount, inventory_size / column_amount) * 64 + Vector2(column_amount + 1, inventory_size / column_amount + 1) * slot_offset
	container.position = Vector2(slot_offset, slot_offset)
	container.add_theme_constant_override("h_separation", slot_offset)
	container.add_theme_constant_override("v_separation", slot_offset)
	_on_inventory_updated()

func _process(_delta: float) -> void:
	self.set_rotation(-self.get_parent().get_parent().rotation)
	if Input.is_action_just_pressed("toggle_inventory"):
		self.visible = !self.visible
		get_tree().paused = !get_tree().paused

func add_modification(idx: int, modification: Dictionary) -> void:
	inventory[idx] = modification
	_on_inventory_updated()

func remove_modification(idx: int) -> void:
	inventory.erase(idx)
	_on_inventory_updated()

func _on_inventory_updated() -> void:
	clear()
	inventory_owner.reset_stats()
	self.is_receiver_powered = false
	container.columns = column_amount
	for item in inventory:
		if item == null:
			continue
		if item.get_item()["name"] != "Generator":
			item.power_off()
	for i in range(inventory.size()):
		if inventory[i] == null:
			continue
		if inventory[i].get_item()["name"] == "Generator":
			power_next_item(i, 0)
			break
	if self.is_receiver_powered:
		apply_item_effects()
	for item in self.inventory:
		var slot = inventory_slot_preload.instantiate()
		slot.slot_dragged.connect(_on_slot_dragged)
		slot.slot_dropped.connect(_on_slot_dropped)
		container.add_child(slot)
		match item:
			null:
				slot.make_space()
			{ "texture": null, "name": null, "description": null, "powered": false }:
				slot.clear()
			_:
				slot.set_modification(item.get_item())

func power_next_item(item_idx: int, limit: int) -> void:
	var next_item_position: int = item_idx + inventory[item_idx].get_item()["direction"].y * container.columns + inventory[item_idx].get_item()["direction"].x
	if next_item_position != clamp(next_item_position, 0, inventory.size() - 1):
		return
	if inventory[item_idx].get_item()["direction"].x != 0 and next_item_position == clamp(next_item_position, item_idx - item_idx % column_amount, item_idx - item_idx % column_amount + column_amount - 1):
		match inventory[next_item_position].get_item()["name"]:
			"Rotate left":
				inventory[clamp(next_item_position, next_item_position - (next_item_position) % column_amount, next_item_position - (next_item_position) % column_amount + column_amount - 1)].power_on(inventory[item_idx].get_item()["direction"], 1)
			"Rotate right":
				inventory[clamp(next_item_position, next_item_position - (next_item_position) % column_amount, next_item_position - (next_item_position) % column_amount + column_amount - 1)].power_on(inventory[item_idx].get_item()["direction"], 2)
			_:
				inventory[clamp(next_item_position, next_item_position - (next_item_position) % column_amount, next_item_position - (next_item_position) % column_amount + column_amount - 1)].power_on(inventory[item_idx].get_item()["direction"], 0)
	else:
		if inventory[item_idx].get_item()["direction"].y != 0:
			match inventory[next_item_position].get_item()["name"]:
				"Rotate left":
					inventory[next_item_position].power_on(inventory[item_idx].get_item()["direction"], 1)
				"Rotate right":
					inventory[next_item_position].power_on(inventory[item_idx].get_item()["direction"], 2)
				_:
					inventory[next_item_position].power_on(inventory[item_idx].get_item()["direction"], 0)
	if inventory[next_item_position].get_item()["name"] == "Receiver":
		self.is_receiver_powered = true
		return
	if inventory[next_item_position].get_item()["name"] in ["Generator"] or limit == 2 * inventory.size():
		return
	power_next_item(next_item_position, limit + 1)
	return

func apply_item_effects() -> void:
	for item in inventory:
		if item == null:
			continue
		if item.get_item()["powered"]:
			match item.get_item()["name"]:
				"Double bullet":
					inventory_owner.bullets_on_shot_modify *= 2

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
		slot_drop(dragged_slot, drop_target)
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
		if container.get_child(i) == slot and container.get_child(i).contained_modification != { null : null }:
			return i
	return -1

func slot_drop(drag_slot: InventorySlot, drop_slot: InventorySlot) -> void:
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
