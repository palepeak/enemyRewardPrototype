class_name Shotgun extends Node2D

var bullet_speed = 2000
var bullet_count = 6
var spread = PI/8
var range = 300

@onready var opposite = $ChamberPoint.global_position.distance_to(global_position)
@export var bullet_scene: PackedScene

func _on_basic_shootable_successful_shoot():
	for n in 8:
		var random_spread = randf_range(-spread, spread)
		var bullet_direction = global_rotation + random_spread
		var bullet = bullet_scene.instantiate()
		bullet.range = range
		bullet.rotation = bullet_direction
		var direction = Vector2(cos(bullet_direction), sin(bullet_direction))
	
		get_tree().get_root().add_child(bullet)
		bullet.fire(
			$BasicShootable/FirePoint.global_position,
			direction,
			bullet_speed
		)
