extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$StartButton.grab_focus()


func _on_start_button_pressed():
	GameStateStore.start_game.emit()


func _on_quit_button_pressed():
	get_tree().quit()

