class_name RecoilForce extends Node2D

@export var recoil_duration_seconds: float
@export var recoil_force_initial: int

var current_forces = []
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target = get_parent().get_parent() as CharacterBody2D
	var new_forces = []
	var velocity = Vector2.ZERO
	for force in current_forces:
		var current_duration = force[1]
		var angle_vector = force[0]
		if current_duration > 0 and target != null:
			new_forces.append([angle_vector, current_duration - delta])
			var cur_force = recoil_force_initial *  current_duration / recoil_duration_seconds
			velocity += -angle_vector * cur_force
		
	current_forces = new_forces
	target.set_velocity(velocity)
	if velocity.length() > 0:
		target.move_and_slide()
	
		
	
func start_recoil():
	current_forces.append([
		Vector2(cos(global_rotation), sin(global_rotation)).normalized(), 
		recoil_duration_seconds
	])
