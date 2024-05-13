class_name EnemyDrop extends Path2D

var _picked_up = false
var _target_area: PlayerHitbox
var _elapsed = 0.0

@onready var audio_stream_pickup = AudioStreamPlayer.new()
var pickup_sfx = preload("res://Resources/reward_pickup.wav")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _picked_up:
		_elapsed += delta
		curve.set_point_position(1, to_local(_target_area.global_position))
		$PathFollow2D.progress_ratio = ease(min(1,_elapsed/0.4), 2)
		if _elapsed >= 0.4:
			audio_stream_pickup.volume_db = 5.0
			audio_stream_pickup.stream = pickup_sfx
			audio_stream_pickup.autoplay = true
			_target_area.add_child.call_deferred(audio_stream_pickup)
			_target_area.drop_collected.emit()
			queue_free()


func _on_pickup_range_area_entered(area):
	if area is PlayerHitbox && !_picked_up:
		_picked_up = true
		_target_area = area
		curve.set_point_out(0, -1.5*to_local(_target_area.global_position))
	
