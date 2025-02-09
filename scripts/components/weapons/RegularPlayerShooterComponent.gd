extends ShootComponent
class_name RegularPlayerShootComponent
	
func shoot(delta: float) -> void:
	if Input.is_action_pressed("shoot") and fire_cooldown_frames == 0:
		fire_cooldown_frames = (1000.0 / shooter_owner.firerate_modify) * delta
		for bs in range(min(shooter_owner.bullets_on_shot_modify, 2 * PI / shooter_owner.spread_modify)):
			var bullet = shooter_owner.bullet_type.instantiate()
			var level_scene: Node2D
			for child in get_tree().get_root().get_children():
				if child is Node2D:
					level_scene = child
			level_scene.add_child(bullet)
			bullet.owner = level_scene
			bullet.global_transform = shot_marker.global_transform
			bullet.speed = shooter_owner.bullet_speed_modify
			bullet.damage = shooter_owner.damage_modify
			var rot_mod: float = 0
			for it_add in range(0, bs + 1):
				rot_mod += it_add * pow(-1, it_add)
			if shooter_owner.bullets_on_shot_modify % 2 == 0:
				bullet.rotation += pow(-1, shooter_owner.bullets_on_shot_modify) * shooter_owner.spread_modify / 2
			bullet.rotation += rot_mod * shooter_owner.spread_modify
