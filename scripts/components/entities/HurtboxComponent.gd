extends Area2D
class_name HurtboxComponent

signal received_damage(damage: int)

@export var health : HealthComponent

func _on_area_entered(hitbox: Area2D) -> void:
	if hitbox != null and hitbox is HitboxComponent:
		health.inflict_damage(hitbox.get_damage())
		received_damage.emit(hitbox.get_damage())
