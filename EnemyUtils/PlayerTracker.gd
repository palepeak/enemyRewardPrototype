class_name PlayerTracker extends Node2D

@export_enum("Nearest", "Primary") var tracking_method: String = "Nearest"
@export var max_distance = 0
var _path_ray: RayCast2D
var _see_player


func _ready():
	_path_ray = RayCast2D.new()
	_path_ray.collision_mask = 0b00000000_00000000_00000000_00001010
	add_child(_path_ray)


func _physics_process(delta):
	var _tracked_player = get_tracked_player()
	if _player_in_range(_tracked_player):
		_path_ray.target_position = to_local(_tracked_player.global_position)


func get_tracked_player() -> Player:
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
	return !_path_ray.is_colliding()


func _player_in_range(tracked_player: Player) -> bool:
	if max_distance <= 0:
		return true
	return tracked_player != null && global_position.distance_to(tracked_player.global_position) < max_distance
