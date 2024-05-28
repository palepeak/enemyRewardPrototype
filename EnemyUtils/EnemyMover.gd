class_name EnemyMover extends Node

@export var active: bool = true
@export var speed: int = 100
@export var player_min_distance: int = -1
@export var player_tracker: PlayerTracker
@export var pathFinder: BasePathFinder
@export var enemy_object: CharacterBody2D
@export var sprite: AnimatedSprite2D

@onready var global_position: Vector2 = enemy_object.global_position

var _active_forces = []
@onready var _current_tracked_location = enemy_object.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !active:
		return
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
	
	var tracked_player
	if player_tracker != null:
		tracked_player = player_tracker.get_tracked_player()
	if tracked_player != null:
		_current_tracked_location = tracked_player.global_position
	var tracked_player_distance = _current_tracked_location.distance_to(enemy_object.global_position)
	if pathFinder.is_navigation_finished() || tracked_player_distance < player_min_distance:
		enemy_object.velocity = velocity_offset
	else:
		var axis = enemy_object.to_local(pathFinder.get_next_path_position()).normalized()
		enemy_object.velocity = axis * speed + velocity_offset
	
	if _current_tracked_location.x > enemy_object.global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false
	enemy_object.move_and_slide()


func apply_force_vector(force: Vector2):
	if active:
		_active_forces.append([force, 1])


func apply_force(direction: float, force: float):
	if active:
		apply_force_vector(Vector2.RIGHT.rotated(direction)*force)
