class_name Shotgun extends Node2D

var gun_bullet_speed = 2000
var gun_bullet_count = 6
var gun_spread = PI/8
var gun_range = 300

@onready var opposite = $ChamberPoint.global_position.distance_to(global_position)
@export var bullet_scene: PackedScene

func _on_basic_shootable_successful_shoot():
	for n in gun_bullet_count:
		var random_spread = randf_range(-gun_spread, gun_spread)
		var bullet_direction = global_rotation + random_spread
		var bullet = bullet_scene.instantiate()
		var direction = Vector2(cos(bullet_direction), sin(bullet_direction))
	
		get_tree().get_root().add_child(bullet)
		bullet.fire(
			$BasicShootable/FirePoint.global_position,
			direction,
			gun_bullet_speed,
			gun_range,
		)
