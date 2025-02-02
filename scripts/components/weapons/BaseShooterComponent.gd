extends Node2D
class_name ShootComponent

@export var shooter_owner: RayCast2D
@export var shot_marker: Marker2D
@export var cooldown_progressbar: TextureProgressBar
@onready var fire_cooldown_frames: float = 0

func _ready() -> void:
	cooldown_progressbar.max_value = (1000.0 / shooter_owner.firerate)
	cooldown_progressbar.hide()

func _process(delta: float) -> void:
	cooldown_progressbar.value = fire_cooldown_frames / delta - 10 * delta
	if cooldown_progressbar.value == cooldown_progressbar.min_value:
		cooldown_progressbar.hide()
	else:
		cooldown_progressbar.show()

func _physics_process(delta: float) -> void:
	if shooter_owner.controlled_by_input: shoot(delta)
	fire_cooldown_frames = maxf(fire_cooldown_frames - delta, 0)

func shoot(delta: float) -> void:
	pass
