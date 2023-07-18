extends Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport = get_viewport_rect().size
	var bound_mouse_position = Vector2(
		max(0, min(mouse_position.x, viewport.x)),
		max(0, min(mouse_position.y, viewport.y))
	)
	var camera_adjustment = (bound_mouse_position - viewport/2)/3
	$Camera2D.global_position = $Player.global_position + camera_adjustment
	$CanvasLayer/FPSCounter.text = str(Engine.get_frames_per_second())
