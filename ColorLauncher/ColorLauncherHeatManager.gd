class_name ColorLauncherHeatManager extends Node

signal shot_successful()

@export var heat_cost: float = 10.0
@export var overheated_recovery_duration: float = 10
@export var heat_recovery: Curve

var _current_heat_value = 0.0
var _emitted_heat_value = -1.0
var _is_overheated = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_overheated:
		var recover_amount = delta * 100 / overheated_recovery_duration
		_current_heat_value -= recover_amount
		_current_heat_value = max(0.0, _current_heat_value)
		if _current_heat_value <= 0.0:
			_is_overheated = false
			$EndSfxPlayer.play()
			$StartSfxPlayer.stop()
			$MainSfxPlayer.stop()
		if _current_heat_value != _emitted_heat_value:
			_emitted_heat_value = _current_heat_value
			HudUiStore.on_player_heat_updated.emit(_current_heat_value, _is_overheated)
	elif _current_heat_value > 0.0:
		var dec = delta * heat_recovery.sample(_current_heat_value/100.0) * (100/overheated_recovery_duration)
		_current_heat_value -= dec
		if _current_heat_value != _emitted_heat_value:
			_emitted_heat_value = _current_heat_value
			HudUiStore.on_player_heat_updated.emit(_current_heat_value, _is_overheated)
	

func try_shoot():
	if _is_overheated:
		return
	
	_current_heat_value += heat_cost
	if _current_heat_value >= 100.0:
		_current_heat_value = min(100.0, _current_heat_value)
		_is_overheated = true
		$StartSfxPlayer.play()
		$MainSfxPlayer.play()
		$EndSfxPlayer.stop()
	_emitted_heat_value = _current_heat_value
	HudUiStore.on_player_heat_updated.emit(_current_heat_value, _is_overheated)
	shot_successful.emit()


func reduce_heat(amount: float):
	_current_heat_value -= amount
	_current_heat_value = max(0.0, _current_heat_value)
