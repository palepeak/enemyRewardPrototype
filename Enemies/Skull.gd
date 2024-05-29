extends Node2D


func _ready():
	if randi_range(1, 2) == 1:
		$HitFlashSprite.flip_h = true
