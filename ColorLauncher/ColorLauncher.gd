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
	if Input.is_action_just_released("launch_color") && can_launch:
		$Line2D.visible = true
		$ColorLauncherHeatManager.try_shoot()
	if Input.is_action_pressed("launch_color"):
		$Line2D.visible = true
	elif Input.is_action_just_pressed("shoot") || Input.get_action_strength("shoot") >= 0.5:
		$Line2D.visible = false
	
	var player = null
	if get_parent() is Player:
		player = get_parent()
	var target_launch_position = ControlsManager.get_aim_target_local(player, max_range)

	raycast.target_position = target_launch_position
	raycast.force_raycast_update()
	
	if (raycast.is_colliding()):
		target_launch_position = to_local(raycast.get_collision_point())
	
	if target_launch_position.length() < 10: 
		# same start and end point path not supported, add in slight offset
		# a delta that is too small causes the same issue
		target_launch_position = Vector2(0, 10)
	
	if position.distance_to(target_launch_position) > max_range:
		target_launch_position = target_launch_position.normalized() * max_range
	elif position.distance_to(target_launch_position) < minimum_range:
		target_launch_position = target_launch_position.normalized() * minimum_range
		
	var point_in_x = (target_launch_position - $Path2D.curve.get_point_position(0)).x * -400/1152
	var point_in_y = min(-200, (target_launch_position - $Path2D.curve.get_point_position(0)).y)
	$Path2D.curve.set_point_position(1, target_launch_position)
	$Path2D.curve.set_point_in(1, Vector2(point_in_x, point_in_y))
	$Path2D.curve.set_point_out(0, Vector2(-point_in_x, point_in_y))
	$Line2D.points = $Path2D.curve.get_baked_points()


func _on_reload_timer_timeout():
	can_launch = true


func _on_color_launcher_heat_manager_shot_successful():
	$AudioStreamPlayer.play()
	
	var bomb_instance = bomb.instantiate() as ColorBomb
	bomb_instance.curve = ($Path2D as Path2D).curve.duplicate()
	bomb_instance.global_position = global_position
	bomb_instance.worldColorStore = worldColorStore
	bomb_instance.residual = bomb_residual
	GameStateStore.get_level().add_child(bomb_instance)


func reduce_heat(amount: float):
	$ColorLauncherHeatManager.reduce_heat(amount)
