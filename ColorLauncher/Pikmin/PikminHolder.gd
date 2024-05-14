class_name PikminHolder extends Node2D

@export var _player: Player
enum PartyMovement {IDLE, LEFT, RIGHT}
var _pikmins = []

var _group_movement: PartyMovement = PartyMovement.IDLE
var _group_movement_emitted: PartyMovement = PartyMovement.IDLE

var _elapsed = 0.0

func _ready():
	_player.register_pikmin_holder(self)


func _process(delta):
	if _player == null:
		return
		
	_elapsed += delta
	if _elapsed < 0.1:
		return
	_elapsed = 0.0
	
	var in_hallway = !GameStateStore.in_room()
	if in_hallway:
		for i in _pikmins.size():
			var adjust_position = Vector2(
				-cos(rotation) * (10*(i/10)), 
				-sin(rotation) * (10*(i/10))
			)
			_pikmins[i].set_party_target_pos(global_position + adjust_position)
	else:
		for i in _pikmins.size():
			var adjust_position = Vector2(
				-sin(rotation) * (10*(i%10)-50) - cos(rotation) * (10*(i/10)), 
				-sin(rotation) * (10*(i/10)) + cos(rotation) * (10*(i%10)-50)
			)
			_pikmins[i].set_party_target_pos(global_position + adjust_position)
	
	$Sprite2D.visible = DebugStore.debug_mode
	
	var target = _player.global_position
	var distance = target - global_position
	rotation = distance.angle()
	global_position = target + distance.normalized() * -25
	
	if _player.velocity == Vector2.ZERO:
		_group_movement = PartyMovement.IDLE
	elif _player.velocity.x < 0: 
		_group_movement = PartyMovement.LEFT
	else:
		_group_movement = PartyMovement.RIGHT
		
	
	if _group_movement_emitted != _group_movement:
		_group_movement_emitted = _group_movement
		for pikmin in _pikmins:
			pikmin.set_party_velocity(_group_movement)


func can_collect_pikmin() -> bool:
	return _pikmins.size() < 100

func collect_pikmin(pikmin: Pikmin):
	_pikmins.append(pikmin)
	$PointLight2D.energy = _pikmins.size()/100.0
