class_name EnemyHitbox extends Area2D

@export var health_manager: CharacterHealthManager


# Called when the node enters the scene tree for the first time.
func process_hit(area: Area2D):
	health_manager.process_hit(area)
