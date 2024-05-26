class_name DefeatObserver extends Node

signal on_defeated()

func _exit_tree():
	on_defeated.emit()
