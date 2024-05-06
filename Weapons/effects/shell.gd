extends RigidBody2D

var original_position
var bounced = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$DespawnTimer.start()
	original_position = position
	linear_velocity = (Vector2(-100 * cos(global_rotation),randf_range(10,-10)))
	angular_velocity = randf_range(-PI, PI)

func _physics_process(_delta):
	if abs(position.y-original_position.y) > 16 and bounced:
		freeze = true
	elif abs(position.y-original_position.y) > 16 and !bounced:
		apply_central_force(Vector2(0, -2000))
		bounced = true

func _on_despawn_timer_timeout():
	queue_free()
