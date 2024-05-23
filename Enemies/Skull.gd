extends CharacterBody2D


func _exit_tree():
	GameStateStore.skull_killed.emit()
