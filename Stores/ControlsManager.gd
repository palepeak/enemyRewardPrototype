extends Node

var using_mouse = true
var _last_mouse_movement = null
func _ready():
    Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _process(_delta):
    var joy_stick_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
    if using_mouse && joy_stick_aim != Vector2.ZERO:
        using_mouse = false
        Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
    elif !using_mouse && Input.get_last_mouse_velocity() != _last_mouse_movement:
        Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        print("using mouse")
        _last_mouse_movement = Input.get_last_mouse_velocity()
        using_mouse = true


func get_aim_target_local(parent: Node2D, max_range: int = 1) -> Vector2:
    if using_mouse:
        return parent.to_local(parent.get_global_mouse_position())
    else:
        var joy_stick_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
        return joy_stick_aim * max_range


func get_aim_target_global(parent: Node2D, max_range: int = 1) -> Vector2:
    return parent.to_global(get_aim_target_local(parent, max_range))

func get_aim_target_viewport(parent: Node2D) -> Vector2:
    if using_mouse:
        var mouse_position = get_viewport().get_mouse_position()
        var viewport = parent.get_viewport_rect().size
        var bound_position = Vector2(
            max(0, min(mouse_position.x, viewport.x)),
            max(0, min(mouse_position.y, viewport.y))
        )
        return (bound_position - viewport/2)/3
    else:
        var joy_stick_aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
        return joy_stick_aim * parent.get_viewport_rect().size/6


func _on_joy_connection_changed(device_id, connected):
    if connected:
        print(Input.get_joy_name(device_id))
    else:
        print("Keyboard")
