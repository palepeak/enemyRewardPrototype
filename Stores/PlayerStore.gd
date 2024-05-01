extends Node

signal player_health_changed(new_health: int)
var primary_player: Player = null
var player_refs = []


func add_player_ref_as_primary(player: Player):
	primary_player = player
	add_player_ref(player)


func add_player_ref(player: Player):
	player_refs.append(player)


func remove_primary_player():
	remove_player_ref(primary_player)


func remove_player_ref(player: Player):
	player_refs.erase(player)
	if primary_player == player:
		primary_player = null


func get_players() -> Array:
	return player_refs


func get_primary_player() -> Player:
	return primary_player
