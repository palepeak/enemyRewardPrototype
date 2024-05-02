class_name BasePathFinder extends NavigationAgent2D


@export var player_tracker: PlayerTracker
@export var root_node: Node2D
@export var recalculate_path_interval: float = 0.5
@export_enum("Nearest", "Primary") var tracking_method: String = "Nearest"

func _ready():
	var _refresh_timer = Timer.new()
	_refresh_timer.wait_time = recalculate_path_interval
	_refresh_timer.timeout.connect(recalculate_path)
	add_child(_refresh_timer)
	_refresh_timer.start()
	DebugStore.debug_mode_changed.connect(set_debug_enabled)


func _get_player_position() -> Vector2:
	var player_position = player_tracker.get_nearest_player_gloabl_position(root_node.global_position)
	if tracking_method == "Primary":
		player_position = player_tracker.get_primary_player_global_position()
	return player_position


func recalculate_path():
	target_position = _get_player_position()
