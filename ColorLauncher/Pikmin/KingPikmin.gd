class_name KingPikmin extends Pikmin


func activate():
	if active:
		return
	var player = $PlayerTracker.get_tracked_player()
	global_position = player.global_position
	active = true
