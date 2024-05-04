extends Node

signal start_game()
signal show_title_screen()
signal show_game_over_screen()

var _current_level: Level

func set_level(level: Level):
	_current_level = level


func get_level() -> Level:
	return _current_level
