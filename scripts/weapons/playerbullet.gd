extends Node2D

@onready var anim = $AnimatedSprite2D
@onready var justCollided: bool = false
@onready var deadlifetime: float = 0
@onready var stored_velocity: Vector2 = self.transform.x
var speed: float
var damage: int = 1

func _process(delta: float) -> void:
	$Label.text = str(self.damage)

func _physics_process(delta: float) -> void:
	position += transform.x * speed * delta
	if justCollided:
		deadlifetime *= delta
		justCollided = false
	if deadlifetime > delta:
		deadlifetime -= delta
		if deadlifetime <= delta:
			queue_free()

func _on_hurtbox_entered(area: Area2D) -> void:
	transform.x = Vector2(transform.x.x * (-0.2), transform.x.y * (-0.2))
	deadlifetime = 20
	justCollided = true
	anim.play("BulletDestroy")
