class_name EnemyColorHurtbox extends Node2D

@export var enemy_health_manager: EnemyHealthManager
@export var enabled = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("ColorHurtbox", true)


func process_hit(color_origin: Vector2, color_radius: int):
	if global_position.distance_to(color_origin) > color_radius || !enabled:
		return
	enemy_health_manager.process_hit(null, 1)
