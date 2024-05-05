class_name ColorLauncher extends Node2D

@export var bomb: PackedScene
@export var bomb_residual: PackedScene
@export var worldColorStore: WorldColorStore
@export var reload_time = 0.5
@export var max_range = 300
@export var minimum_range = 0

@onready var reload_timer: Timer = $Timer
@onready var raycast: RayCast2D = $RayCast2D
var can_launch = true


# Called when the node enters the scene tree for the first time.
func _ready():
	reload_timer.wait_time = reload_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("launch_color") && can_launch:
		_fire()
		
	var bar = $ReloadBar as TextureProgressBar
	var value = (reload_timer.wait_time - reload_timer.time_left)/reload_timer.wait_time
	bar.value = value * 100	
	
	var local_mouse_position = to_local(get_global_mouse_position())
	raycast.target_position = local_mouse_position
	raycast.force_raycast_update()
	
	var target_launch_position = local_mouse_position
	if (raycast.is_colliding()):
		target_launch_position = to_local(raycast.get_collision_point())
	
	if position.distance_to(target_launch_position) > max_range:
		target_launch_position = target_launch_position.normalized() * max_range
	elif position.distance_to(target_launch_position) < minimum_range:
		target_launch_position = target_launch_position.normalized() * minimum_range
		
	var point_in_x = (target_launch_position - $Path2D.curve.get_point_position(0)).x * -400/1152
	var point_in_y = min(-200, (target_launch_position - $Path2D.curve.get_point_position(0)).y)
	# $Sprite2D2.global_position = $Sprite2D2.get_global_mouse_position()
	$Path2D.curve.set_point_position(1, target_launch_position)
	$Path2D.curve.set_point_in(1, Vector2(point_in_x, point_in_y))
	$Path2D.curve.set_point_out(0, Vector2(-point_in_x, point_in_y))
	$Line2D.points = $Path2D.curve.get_baked_points()
	
func _fire():
	$AudioStreamPlayer.play()
	can_launch = false
	reload_timer.start()
	
	var bomb_instance = bomb.instantiate() as ColorBomb
	bomb_instance.curve = ($Path2D as Path2D).curve.duplicate()
	bomb_instance.global_position = global_position
	bomb_instance.worldColorStore = worldColorStore
	bomb_instance.residual = bomb_residual
	get_tree().root.add_child(bomb_instance)


func _on_reload_timer_timeout():
	can_launch = true
