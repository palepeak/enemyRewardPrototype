class_name RandomPathFinder extends BasePathFinder


func _ready():
	var _refresh_timer = Timer.new()
	_refresh_timer.wait_time = recalculate_path_interval
	_refresh_timer.timeout.connect(recalculate_path)
	add_child(_refresh_timer)
	_refresh_timer.start()
	DebugStore.debug_mode_changed.connect(set_debug_enabled)


func _get_player_position() -> Vector2:
	var random_angle = randf_range(0.0, 2.0*PI)
	return root_node.global_position + Vector2.DOWN.rotated(random_angle) * randi_range(100, 300)
