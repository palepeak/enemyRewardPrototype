class_name WinScreen extends Control

@onready var time_label: Label = $VBoxContainer2/TimeLabel


func show_screen():
	$VBoxContainer2/StartButton.grab_focus()
	($AnimationPlayer as AnimationPlayer).play("show")
	var start_time = GameStateStore._start_time
	var current_time = Time.get_ticks_msec()
	var seconds = (current_time - start_time)/1000 #warning-ignore:integer_division
	var minutes = seconds / 60 #warning-ignore:integer_division
	var hours = seconds / 3600 #warning-ignore:integer_division
	time_label.text = "Time elapsed: %02d:%02d:%02d" % [hours, minutes%60, seconds%60]


func _on_quit_button_pressed():
	GameStateStore.show_title_screen.emit()


func _on_start_button_pressed():
	GameStateStore.start_game()
