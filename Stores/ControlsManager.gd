extends Node

signal on_using_mouse()
signal on_using_controller()

var using_mouse = true
var _last_mouse_movement = null

var _aim_target_local = Vector2(0, 0)
var _aim_target_center_mode_local = Vector2(0, 0)
var _current_aim_target_local = Vector2(0, 0)
var _controller_aim_center_mode = false
var _controller_aim_sensitivity = 8.0


func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)


func _process(delta):
	var joy_stick_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if using_mouse && joy_stick_aim != Vector2.ZERO:
		using_mouse = false
		on_using_controller.emit()
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	elif !using_mouse && Input.get_last_mouse_velocity() != _last_mouse_movement:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		on_using_mouse.emit()
		_last_mouse_movement = Input.get_last_mouse_velocity()
		using_mouse = true
	
	if Input.is_action_just_pressed("switch_controller_aim_mode"):
		_controller_aim_center_mode = !_controller_aim_center_mode
	
	if _controller_aim_center_mode:
		_aim_target_center_mode_local = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		_current_aim_target_local = _aim_target_center_mode_local
	else:
		var aim_target = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
		if (aim_target.length() > 0.99):
			_aim_target_local = (aim_target*delta*_controller_aim_sensitivity*2 + _aim_target_local)
		else:
			_aim_target_local = (aim_target*delta*_controller_aim_sensitivity + _aim_target_local)
			
		if _aim_target_local.length() > 1:
			_aim_target_local = _aim_target_local.normalized()
		_current_aim_target_local = _aim_target_local


func get_aim_target_local(player: Player, max_range: int = 1) -> Vector2:
	return player.to_local(get_aim_target_global(player, max_range))


func get_aim_target_global(player: Player, max_range: int = 1) -> Vector2:
	if using_mouse:
		return player.get_global_mouse_position()
	else:
		return player.to_global(_current_aim_target_local * max_range)

func get_aim_target_viewport(parent: Node2D) -> Vector2:
	if using_mouse:
		var mouse_position = get_viewport().get_mouse_position()
		var viewport = parent.get_viewport_rect().size
		var bound_position = Vector2(
			max(0, min(mouse_position.x, viewport.x)),
			max(0, min(mouse_position.y, viewport.y))
		)
		return (bound_position - viewport/2)
	else:
		return _current_aim_target_local * parent.get_viewport_rect().size/2


func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")
