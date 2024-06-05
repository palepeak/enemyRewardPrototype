class_name EnemyDropFragment extends Path2D

var _elapsed = 0.0

@onready var target_player = PlayerStore.get_nearest_player(global_position)
@onready var target_duration = randf_range(0.4, 0.6)
@onready var camera = GameStateStore.get_level().get_camera() as Camera2D

func _ready():
	var target_angle = global_rotation
	global_rotation = 0
	curve.set_point_out(0, Vector2(
		(cos(target_angle)+sin(target_angle)*randf_range(-1, 1)),
		(sin(target_angle)+cos(target_angle)*randf_range(-1, 1)),
	).normalized() * 300)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_elapsed += delta
	var target_location = camera.get_screen_center_position() + Vector2(395, 186)
	curve.set_point_position(1, to_local(target_location))
	$PathFollow2D.progress_ratio = ease(min(1,_elapsed/target_duration), 2)
	if _elapsed >= target_duration:
		if target_player != null:
			target_player.collect_fragment(randf_range(0.01, 0.02))
		queue_free()

