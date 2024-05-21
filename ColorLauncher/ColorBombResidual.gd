class_name ColorBombResidual extends AnimatedSprite2D

var pikmin: Pikmin


func enable_pikmin():
	if pikmin != null:
		pikmin.global_position = global_position
		pikmin.active = true
