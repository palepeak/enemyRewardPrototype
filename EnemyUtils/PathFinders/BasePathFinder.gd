class_name BasePathFinder extends NavigationAgent2D


@export var player_tracker: PlayerTracker
@export var root_node: Node2D
@export var recalculate_path_interval: float = 0.5


func _ready():
	var _refresh_timer = Timer.new()
	_refresh_timer.wait_time = recalculate_path_interval
	_refresh_timer.timeout.connect(recalculate_path)
	add_child(_refresh_timer)
	_refresh_timer.start()
	DebugStore.debug_mode_changed.connect(set_debug_enabled)


func _get_player_position() -> Vector2:
	var player = player_tracker.get_tracked_player()
	if player == null:
		return player_tracker.global_position
	return player.global_position


func recalculate_path():
	target_position = _get_player_position()
