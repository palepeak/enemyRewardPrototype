extends Node

signal player_health_changed(new_health: int)
var _primary_player: Player = null
var _player_refs = []


func add_player_ref_as_primary(player: Player):
	_primary_player = player
	add_player_ref(player)


func add_player_ref(player: Player):
	_player_refs.append(player)


func remove_primary_player():
	remove_player_ref(_primary_player)


func remove_player_ref(player: Player):
	_player_refs.erase(player)
	if _primary_player == player:
		_primary_player = null


func get_players() -> Array:
	return _player_refs


func get_primary_player() -> Player:
	return _primary_player
