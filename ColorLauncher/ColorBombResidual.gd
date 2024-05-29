class_name ColorBombResidual extends AnimatedSprite2D

var pikmin: Pikmin


func enable_pikmin():
	return
	if pikmin is KingPikmin:
		pikmin.global_position = global_position
		pikmin.active = true
	else:
		pikmin.queue_free()
