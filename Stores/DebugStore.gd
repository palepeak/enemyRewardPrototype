extends Node

signal debug_mode_changed(debug_mode: bool)

var debug_mode = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug_toggle"):
		debug_mode = !debug_mode
		debug_mode_changed.emit(debug_mode)
