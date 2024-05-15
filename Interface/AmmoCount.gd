class_name AmmoCount extends Control

@export var for_controller = false

# Called when the node enters the scene tree for the first time.
func _ready():
	GameStateStore.toggle_pause_screen.connect(func(): visible = !get_tree().paused)
	ControlsManager.on_using_mouse.connect(func (): visible = !for_controller)
	ControlsManager.on_using_controller.connect(func (): visible = for_controller)
	HudUiStore.on_current_clip_ammo_changed.connect(update_ammo)


func update_ammo(ammo_count):
	$CurrentAmmo.text = str(ammo_count % 7)
