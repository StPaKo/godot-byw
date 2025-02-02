extends Area2D
class_name HitboxComponent

@export var damage: int = 1

func set_damage(damage_on_hit: int) -> void:
	self.damage = damage_on_hit
func get_damage() -> int:
	return self.damage
