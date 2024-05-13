class_name EnemyHitbox extends Area2D

@export var health_manager: CharacterHealthManager
@export var enemy_mover: EnemyMover


# Called when the node enters the scene tree for the first time.
func process_hit(area: Area2D, damage: float, force: float = 0.0):
	health_manager.process_hit(area, damage)
	if enemy_mover != null:
		enemy_mover.apply_force(area.global_rotation, force)
