extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	show_screen()


func show_screen():
	visible = true
	$StartButton.grab_focus()


func _on_start_button_pressed():
	GameStateStore.start_game()


func _on_quit_button_pressed():
	get_tree().quit()

