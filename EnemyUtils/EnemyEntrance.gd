class_name EnemyEntrance extends Node2D

var _enabled = false
var enemy_node: Node2D
var delay = 1.5
var cur_delay = delay


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	visible = _enabled
	if enemy_node == null:
		return
	
	enemy_node.visible = _enabled
	if _enabled:
		cur_delay -= delta
		cur_delay = max(0.0, cur_delay)
		var progress = 1-(cur_delay/delay)
		$ProgressBar.value = progress*100.0
		enemy_node.global_scale = Vector2(progress, progress)
		if cur_delay == 0.0:
			enemy_node.global_scale = Vector2(1.0, 1.0)
			if enemy_node.has_method("activate"):
				enemy_node.activate()
			$AudioStreamPlayer2D.play()
			_enabled = false
			enemy_node = null


func activate():
	var timer = Timer.new()
	timer.one_shot = true
	timer.autostart = true
	timer.wait_time = randf()
	timer.timeout.connect(func(): _enabled = true)
	add_child(timer)


func _on_audio_stream_player_2d_finished():
	queue_free()
