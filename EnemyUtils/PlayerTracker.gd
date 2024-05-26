class_name PlayerTracker extends Node2D

@export var enabled = true
@export var calculate_vision = true
@export_enum("Nearest", "Primary") var tracking_method: String = "Nearest"
@export var max_distance = 0
var _path_ray: RayCast2D
var _see_player


func _ready():
	if calculate_vision:
		_path_ray = RayCast2D.new()
		_path_ray.collision_mask = 0b00000000_00000000_00000000_00001000
		add_child(_path_ray)
		
		var tick_timer = Timer.new()
		tick_timer.wait_time = 0.1
		tick_timer.timeout.connect(_retrack_player)
		tick_timer.autostart = true
		add_child(tick_timer)


func _retrack_player():
	if !enabled:
		return
	var _tracked_player = get_tracked_player()
	if _tracked_player != null && _player_in_range(_tracked_player):
		_path_ray.target_position = to_local(_tracked_player.global_position)


func get_tracked_player() -> Player:
	if !enabled:
		return null
	var player
	if tracking_method == "Nearest":
		player = _get_nearest_player(global_position)
	else:
		player = _get_primary_player()
	if _player_in_range(player):
		return player
	return null


func _get_nearest_player(position: Vector2) -> Player:
	return PlayerStore.get_nearest_player(position)


func _get_primary_player() -> Player:
	return PlayerStore.get_primary_player()


func can_see_player() -> bool:
	if !enabled || !calculate_vision:
		return false
	return !_path_ray.is_colliding()


func _player_in_range(tracked_player: Player) -> bool:
	if !enabled:
		return false
	if max_distance <= 0:
		return true
	return tracked_player != null && global_position.distance_to(tracked_player.global_position) < max_distance
