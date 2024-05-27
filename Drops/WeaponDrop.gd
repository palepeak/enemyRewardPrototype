class_name WeaponDrop extends Node2D

@export var weapon: PackedScene
var _weapon_instance: Node2D


func _ready():
	_weapon_instance = weapon.instantiate()
	add_child(_weapon_instance)
	for child in _weapon_instance.get_children():
		if child is Hand:
			child.visible = false


func _on_interactable_on_interaction():
	var player: Player = PlayerStore.get_primary_player()
	player.add_gun(_weapon_instance)
	queue_free()
