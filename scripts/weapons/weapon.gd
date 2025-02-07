extends RayCast2D

var lock_rotation: bool = false
var looked_object_position: Vector2 = Vector2(0, 0)
@export var shooter: ShootComponent
@export var bullet_type: PackedScene
@export var bullet_speed: float = 1000
var bullet_speed_modify: float
@export var bullets_on_shot: int = 1
var bullets_on_shot_modify: int
@export var firerate: float = 50
var firerate_modify: float
@export var spread: float = PI / 12
var spread_modify: float
@export var controlled_by_input: bool = false

func _ready() -> void:
	reset_stats()

func _physics_process(_delta: float) -> void:
	if lock_rotation:
		self.look_at(looked_object_position)
	else:
		self.look_at(get_global_mouse_position())

func set_rotation_lock(is_locked: bool, look_at_position: Vector2 = Vector2(0, 0)):
	self.lock_rotation = is_locked
	if is_locked:
		self.looked_object_position = look_at_position

func reset_stats() -> void:
	self.bullet_speed_modify = self.bullet_speed
	self.bullets_on_shot_modify = self.bullets_on_shot
	self.firerate_modify = self.firerate
	self.spread_modify = self.spread

func _on_force_shot(delta: float) -> void:
	shooter.shoot(delta)
