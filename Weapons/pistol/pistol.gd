class_name Pistol extends Node2D

var bullet_speed = 1000
@onready var opposite = $ChamberPoint.global_position.distance_to(global_position)
@export var bullet_scene: PackedScene
var gun_range = 3000


func _on_shootable_successful_shoot():
	var bullet = bullet_scene.instantiate()
	bullet.global_rotation = global_rotation
	var direction = Vector2(cos(global_rotation), sin(global_rotation))
	
	GameStateStore.get_level().add_child(bullet)
	print($BasicShootable/FirePoint.global_position)
	bullet.fire(
		$BasicShootable/FirePoint.global_position,
		direction,
		bullet_speed,
		gun_range,
	)
