extends RayCast2D

var lock_rotation: bool = false
var looked_object_position: Vector2 = Vector2(0, 0)
@export var bullet_type: PackedScene
@export var bullet_speed: float = 1000
@export var bullets_on_shot: int = 1
@export var firerate: float = 50
@export var spread: float = PI / 12
@export var controlled_by_input: bool = false

func _physics_process(_delta: float) -> void:
	if lock_rotation:
		self.look_at(looked_object_position)
	else:
		self.look_at(get_global_mouse_position())

func set_rotation_lock(is_locked: bool, look_at_position: Vector2 = Vector2(0, 0)):
	self.lock_rotation = is_locked
	if is_locked:
		self.looked_object_position = look_at_position

func _on_force_shot(delta: float) -> void:
	for child in self.get_children():
		if child.name == "Components":
			for component in child.get_children():
				if component is ShootComponent:
					component.shoot(delta)
					break
