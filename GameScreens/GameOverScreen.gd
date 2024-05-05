extends Control


func show_screen():
	visible = true
	($AnimationPlayer as AnimationPlayer).play("show")


func _on_start_button_pressed():
	GameStateStore.start_game()


func _on_quit_button_pressed():
	GameStateStore.show_title_screen.emit()
