class_name PlayerTracker extends Node



func get_nearest_player(position: Vector2) -> Player:
	return PlayerStore.get_nearest_player(position)


func get_nearest_player_gloabl_position(position: Vector2) -> Vector2:
	return PlayerStore.get_nearest_player_gloabl_position(position)
	


func get_primary_player_global_position() -> Vector2:
	return PlayerStore.get_primary_player().global_position
