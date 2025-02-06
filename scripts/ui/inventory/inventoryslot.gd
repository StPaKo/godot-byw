extends Control
class_name InventorySlot

@onready var info_panel : Panel = $InfoPanel
@onready var modification_icon : Sprite2D = $InnerBorder/ItemIcon
@onready var slot_background : Sprite2D = $InnerBorder/Background
@onready var modification_name_label : Label = $InfoPanel/ItemName
@onready var modification_description_label : Label = $InfoPanel/Description
@onready var modification_power_status_label : Label = $InfoPanel/PowerStatus
@onready var outer_border : ColorRect = $OuterBorder
var contained_modification : Dictionary = { "texture": null, "name": null, "description": null, "powered": false }

signal slot_dragged(slot: InventorySlot)
signal slot_dropped

func _ready() -> void:
	slot_background.texture = ImageTexture.create_from_image(Image.load_from_file("res://assets/ui/modifications/powered 16x16.png"))

func clear() -> void:
	contained_modification = { "texture": null, "name": null, "description": null, "powered": false }

func _process(delta: float) -> void:
	if contained_modification["powered"]:
		slot_background.visible = true
	else:
		slot_background.visible = false

func set_modification(new_modification : Dictionary) -> void:
	self.contained_modification = new_modification
	self.modification_icon.texture = new_modification["texture"]
	self.modification_name_label.text = new_modification["name"]
	self.modification_description_label.text = new_modification["description"]
	if new_modification["powered"]:
		self.modification_power_status_label.text = "Powered"
	else:
		self.modification_power_status_label.text = "Unpowered"

func _on_mouse_entered() -> void:
	if contained_modification["texture"] != null and contained_modification["name"] != null and contained_modification["description"] != null:
		info_panel.visible = true

func _on_mouse_exited() -> void:
	info_panel.visible = false

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				outer_border.modulate = Color(0, 0, 0)
				if not contained_modification["name"] in ["Generator", "Receiver"]:
					slot_dragged.emit(self)
			else:
				outer_border.modulate = Color(1, 1, 1)
				slot_dropped.emit()
