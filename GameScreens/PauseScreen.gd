class_name PauseScreen extends Control


func _on_resume_button_pressed():
	GameStateStore.toggle_pause_screen.emit()


func _on_return_button_pressed():
	get_tree().paused = false
	GameStateStore.show_title_screen.emit()


func _on_restart_button_pressed():
	get_tree().paused = false
	GameStateStore.start_game()
