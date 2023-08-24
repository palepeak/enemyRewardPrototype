extends Node

func _ready():
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _process(_delta):
	pass
	
	
func _on_joy_connection_changed(device_id, connected):
	if connected:
		print(Input.get_joy_name(device_id))
	else:
		print("Keyboard")
		
# will return a global screen position relative to the screen center global position
func get_aim_position(player: Player) -> Vector2:
	return player.get_global_mouse_position()
