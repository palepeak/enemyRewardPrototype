extends Node

signal game_started()
signal show_title_screen()
signal show_game_over_screen()
signal toggle_pause_screen()
signal show_win_screen()

var first_throw = true
signal on_first_throw()

var _current_level: Level
var _start_time: int

var _clear_target: int = 999
var _dropped_drops = []
var _current_room: RoomArea2D = null

func start_game():
	_start_time = Time.get_ticks_msec()
	game_started.emit()
	_dropped_drops = []
	

func get_start_time() -> int:
	return _start_time


func set_level(level: Level):
	_current_level = level


func remove_level():
	if _current_level != null:
		_current_level.queue_free()
	_current_level = null
	_clear_target = 999
	first_throw = true


func get_level() -> Level:
	return _current_level


func add_to_level(node: Node2D):
	var level = get_level()
	if level != null:
		level.add_child.call_deferred(node)

func set_clear_percent(target): _clear_target = target
func get_clear_percent() -> int: return _clear_target


func get_first_drop(path: String) -> bool:
	if _dropped_drops.has(path):
		return false
	_dropped_drops.append(path)
	return true


func set_room(area: RoomArea2D):
	_current_room = area


func get_current_room() -> RoomArea2D:
	return _current_room


func in_room() -> bool: return _current_room != null


func emit_first_throw():
	first_throw = false
	on_first_throw.emit()
