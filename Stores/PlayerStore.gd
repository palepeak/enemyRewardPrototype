extends Node

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
	
	player.queue_free()


func clear_players():
	for player_ref in _player_refs:
		player_ref.queue_free()
	
	_player_refs = []
	_primary_player = null


func get_players() -> Array:
	return _player_refs


func get_primary_player() -> Player:
	return _primary_player