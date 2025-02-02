extends CharacterBody2D

@export var speed: float = 175.0
@export var friction: float = 0.25
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var speedMultiplier: float = 0
var dashCooldown: float = 0
var isDashed: bool = false
var dashDirection: Vector2 = Vector2(0, 0)
var animationDirection: Vector2 = Vector2(0, 1)
var animation_frame: int

func _physics_process(delta: float) -> void:
	var direction: Vector2 = Vector2(
		-int(Input.is_action_pressed("move_left")) + int(Input.is_action_pressed("move_right")),
		-int(Input.is_action_pressed("move_up")) + int(Input.is_action_pressed("move_down"))
	).normalized()
	movement(direction, delta)
	animation_and_sound(direction)
	move_and_slide()

func _process(_delta: float) -> void:
	z_index = floor(global_position.y)

func movement(direction: Vector2, delta: float) -> void:
	if dashCooldown == 0 and Input.is_action_just_pressed("dash"):
		isDashed = true
		dashCooldown = 25 * delta
		dashDirection = direction
	if dashCooldown <= 20 * delta:
		isDashed = false
	if direction.length() != 0:
		speedMultiplier += 0.2
	else:
		speedMultiplier -= 0.1
	speedMultiplier = clamp(speedMultiplier, 0, 1)
	if isDashed:
		speedMultiplier = 2
	if not isDashed:
		velocity += speedMultiplier * direction * speed
	else:
		velocity += speedMultiplier * dashDirection * speed
	velocity -= friction * velocity
	dashCooldown -= delta
	dashCooldown = maxf(dashCooldown, 0)

func animation_and_sound(moveDirection: Vector2) -> void:
	if round(moveDirection.x) == -1:
		sprite.play("RunLeft")
		animationDirection = Vector2(-1, 0)
	elif round(moveDirection.x) == 1:
		sprite.play("RunRight")
		animationDirection = Vector2(1, 0)
	elif round(moveDirection.y) == -1:
		sprite.play("RunUp")
		animationDirection = Vector2(0, -1)
	elif round(moveDirection.y) == 1:
		sprite.play("RunDown")
		animationDirection = Vector2(0, 1)
	if velocity.length() < 100:
		match animationDirection:
			Vector2(-1, 0):
				sprite.play("IdleLeft")
			Vector2(1, 0):
				sprite.play("IdleRight")
			Vector2(0, -1):
				sprite.play("IdleUp")
			Vector2(0, 1):
				sprite.play("IdleDown")
	self.animation_frame = sprite.frame
	# if sprite.frame % 4 == 0 and sprite.animation in ["RunRight", "RunLeft", "RunUp", "RunDown"] and !$AudioStreamPlayer.playing:
	# 	$AudioStreamPlayer.play()
	# if sprite.frame % 4 == 1 and sprite.animation in ["RunRight", "RunLeft", "RunUp", "RunDown"]:
	# 	$AudioStreamPlayer.stop()


func _on_animation_changed() -> void:
	sprite.frame = self.animation_frame

func _on_health_depleted() -> void:
	get_tree().quit()
