extends Control
class_name InventorySlot

@onready var info_panel : Panel = $InfoPanel
@onready var modification_icon : Sprite2D = $InnerBorder/ItemIcon
@onready var modification_name_label : Label = $InfoPanel/ItemName
@onready var modification_description_label : Label = $InfoPanel/Description
var contained_modification = null

func clear() -> void:
	modification_icon = null

func set_modification(new_modification : Dictionary) -> void:
	self.contained_modification = new_modification
	self.modification_icon.texture = new_modification["texture"]
	self.modification_name_label.text = new_modification["name"]
	self.modification_description_label.text = new_modification["description"]

func _on_mouse_entered() -> void:
	if contained_modification != null:
		info_panel.visible = true

func _on_mouse_exited() -> void:
	info_panel.visible = false
