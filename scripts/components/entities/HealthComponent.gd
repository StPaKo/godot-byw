extends Node
class_name HealthComponent

@export var max_health: int = 10
@onready var current_health: int = max_health

signal current_health_changed(difference: int)
signal health_depleted

func inflict_damage(damage: int) -> void:
	current_health = maxi(current_health - damage, 0)
	current_health_changed.emit(damage)
	if current_health == 0:
		health_depleted.emit()
