class_name EnemyMover extends Node

@export var active: bool = true
@export var speed: int = 100
@export var player_min_distance: int = -1
@export var pathFinder: BasePathFinder
@export var enemy_object: CharacterBody2D
@export var sprite: AnimatedSprite2D

@onready var global_position: Vector2 = enemy_object.global_position

var _active_forces = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var new_forces = []
	var velocity_offset = Vector2.ZERO
	for force in _active_forces:
		var current_duration = force[1]
		var force_vector = force[0]
		if current_duration > 0 and enemy_object != null:
			new_forces.append([force_vector, current_duration - delta])
			var cur_force = force_vector * ease(current_duration, 3)
			velocity_offset += cur_force
		
	_active_forces = new_forces
	
	var nearest_player = PlayerStore.get_nearest_player_gloabl_position(enemy_object.global_position)
	var nearest_player_distance = nearest_player.distance_to(enemy_object.global_position)
	if !active || pathFinder.is_target_reached() || nearest_player_distance < player_min_distance:
		enemy_object.velocity = velocity_offset
	else:
		var axis = enemy_object.to_local(pathFinder.get_next_path_position()).normalized()
		enemy_object.velocity = axis * speed + velocity_offset
	
	if nearest_player.x > enemy_object.global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	enemy_object.move_and_slide()


func apply_force_vector(force: Vector2):
	_active_forces.append([force, 1])


func apply_force(direction: float, force: float):
	apply_force_vector(Vector2.RIGHT.rotated(direction)*force)
