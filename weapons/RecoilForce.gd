class_name RecoilForce extends Node2D

@export var recoil_duration_seconds: float
@export var recoil_force_initial: int

var current_duration = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var angle_vector = Vector2(cos(global_rotation), sin(global_rotation)).normalized()
	var target = get_parent().get_parent() as CharacterBody2D
	if current_duration > 0 and target != null:
		var cur_force = recoil_force_initial *  current_duration / recoil_duration_seconds
		target.velocity = -angle_vector * cur_force
		
		target.move_and_slide()
		current_duration -= delta
			
		
	
func start_recoil():
	current_duration = recoil_duration_seconds
