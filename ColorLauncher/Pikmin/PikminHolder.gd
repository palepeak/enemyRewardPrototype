class_name PikminHolder extends Node2D

@export var _player: Player
enum PartyMovement {IDLE, LEFT, RIGHT}
var _pikmins = []
var _cur_fragment_progress = 0.0

var _group_movement: PartyMovement = PartyMovement.IDLE
var _group_movement_emitted: PartyMovement = PartyMovement.IDLE

var pikmin_scene = preload("res://ColorLauncher/Pikmin/Pikmin.tscn")
var _elapsed = 0.0

var _collected_pikmin = false

func _ready():
	_player.register_pikmin_holder(self)


func _process(delta):
	if _player == null:
		return
		
	_elapsed += delta
	if _elapsed < 0.1:
		return
	_elapsed = 0.0
	
	for i in _pikmins.size():
		var target_pos = _get_target_position(i)
		_pikmins[i].set_party_target_pos(target_pos)

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
			if pikmin != null:
				pikmin.set_party_velocity(_group_movement)


func can_collect_pikmin() -> bool:
	return _pikmins.size() < 100


func collect_pikmin(pikmin: Pikmin):
	if !_collected_pikmin:
		_collected_pikmin = true
		HudUiStore.show_ember_progress.emit()
	pikmin.phase_to(_player.global_position)
	_pikmins.append(pikmin)
	$PointLight2D.energy = _pikmins.size()/100.0
	HudUiStore.on_ember_count_changed.emit(_pikmins.size())


func pop_pikmin() -> Pikmin:
	var popped_pikmin = _pikmins.pop_front()
	if popped_pikmin != null:
		popped_pikmin.remove_from_party()
		HudUiStore.on_ember_count_changed.emit(_pikmins.size())
	return popped_pikmin


func add_pikmin():
	if _pikmins.size() < 100:
		var new_pikmin = pikmin_scene.instantiate() as Pikmin
		new_pikmin.global_position = _player.global_position
		# TODO figure out a better place to add the pikmins to
		# Pikmins currently can't persist between levels
		GameStateStore.add_to_level(new_pikmin)


func collect_fragment(fragment_value: float):
	$FragmentPickup.play()
	_cur_fragment_progress += fragment_value
	_cur_fragment_progress = min(_cur_fragment_progress, 1.0)
	if _cur_fragment_progress >= 1.0 && _pikmins.size() < 100:
		add_pikmin()
		_cur_fragment_progress = 0.0
		$NewEmberPlayer.play()
	HudUiStore.on_ember_progress_changed.emit(_cur_fragment_progress)


func _get_target_position(index):
	var in_hallway = !GameStateStore.in_room()
	if in_hallway:
		var adjust_position = Vector2(
			-cos(rotation) * (10*(index/10)), 
			-sin(rotation) * (10*(index/10))
		)
		return global_position + adjust_position
	else:
		var h = _order_index_to_position(index%10)
		var adjust_position = Vector2(
			-sin(rotation) * (10*h-50) - cos(rotation) * (10*(index/10)), 
			-sin(rotation) * (10*(index/10)) + cos(rotation) * (10*h-50)
		)
		return global_position + adjust_position


func _order_index_to_position(order) -> int:
	if order == 0: return 4
	elif order == 1: return 5
	elif order == 2: return 3
	elif order == 3: return 6
	elif order == 4: return 2
	elif order == 5: return 7
	elif order == 6: return 1
	elif order == 7: return 8
	elif order == 8: return 0
	else: return 9
	
