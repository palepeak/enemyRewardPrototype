class_name PlayerTracker extends Node


func get_nearest_player_gloabl_position(position: Vector2) -> Vector2:
	var players = PlayerStore.get_players()
	if players.is_empty():
		return position
	
	var nearest_player = players[0]
	var nearest_distance = position.distance_to(players[0].global_position)
	for player in players:
		var current_distance = position.distance_to(player.global_position)
		if current_distance < nearest_distance:
			nearest_player = player
			nearest_distance = current_distance
	
	return nearest_player.global_position
	


func get_primary_player_global_position() -> Vector2:
	return PlayerStore.get_primary_player().global_position
