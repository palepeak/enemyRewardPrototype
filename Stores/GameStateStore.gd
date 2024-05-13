extends Node

signal game_started()
signal show_title_screen()
signal show_game_over_screen()
signal toggle_pause_screen()
signal show_win_screen()

var _current_level: Level
var _start_time: int

var _clear_target: int = 999
var _dropped_drops = {}

func start_game():
	_start_time = Time.get_ticks_msec()
	game_started.emit()
	

func get_start_time() -> int:
	return _start_time


func set_level(level: Level):
	_current_level = level


func remove_level():
	if _current_level != null:
		_current_level.queue_free()
	_current_level = null
	_clear_target = 999


func get_level() -> Level:
	return _current_level
	
func set_clear_percent(target): _clear_target = target
func get_clear_percent() -> int: return _clear_target


func get_first_drop(path: String) -> bool:
	if _dropped_drops.has(path) && _dropped_drops[path]:
		return false
	_dropped_drops[path] = true
	return true
