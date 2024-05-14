class_name ColorBomb extends Path2D

var done = false
var elapsed = 0.0
var residual: PackedScene = null
var pikmin: Pikmin = null
@onready var worldColorStore: WorldColorStore = GameStateStore.get_level().get_world_color_store()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var path = $PathFollow2D as PathFollow2D
	
	elapsed += delta
	path.progress_ratio = ease(elapsed, 1)
	if path.progress_ratio >= 1.0 && !done:
		done = true 
		var end = Vector2i(to_global(curve.get_point_position(1)))
		worldColorStore.post_draw_color_line(end, end)
		$AnimationPlayer.play("fade_out")
		
		if residual != null:
			var residual_instance = residual.instantiate()
			residual_instance.pikmin = pikmin
			residual_instance.global_position = $PathFollow2D/ColorBomb.global_position
			worldColorStore.add_child(residual_instance)
