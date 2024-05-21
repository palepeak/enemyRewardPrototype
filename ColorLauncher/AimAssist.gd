class_name AimAssist extends Line2D

signal grid_aim_changed()

@onready var max_range: int = get_parent().max_range
@onready var minimum_range = get_parent().minimum_range
@onready var raycast: RayCast2D = $RayCast2D
@export var grid_size: int = 64

var _held_down: bool = false
var _held_down_time_count = 0.0
var _held_down_position: Vector2
var _held_down_visited_positions = []


func _ready():
	$GridSprite.scale = Vector2(grid_size/32, grid_size/32)


func _process(delta):
	var player = null
	if get_parent().get_parent() is Player:
		player = get_parent().get_parent()
	var target_launch_position = ControlsManager.get_aim_target_global(player, max_range)
	
	var target_position_local = to_local(target_launch_position)
	if position.distance_to(target_position_local) > max_range:
		target_position_local = target_position_local.normalized() * max_range
		target_launch_position = to_global(target_position_local)
	elif position.distance_to(target_position_local) < minimum_range:
		target_position_local = target_position_local.normalized() * minimum_range
		target_launch_position = to_global(target_position_local)
		
	#Processing grid snap if held down
	var _held_down_aim_changed = false
	if _held_down:
		var distance_x = target_launch_position.x - _held_down_position.x
		var distance_y = target_launch_position.y - _held_down_position.y
		var _held_down_position_orig = _held_down_position
		while distance_x > grid_size:
			_held_down_position += Vector2(grid_size, 0)
			distance_x = target_launch_position.x - _held_down_position.x
		while distance_x < -grid_size:
			_held_down_position -= Vector2(grid_size, 0)
			distance_x = target_launch_position.x - _held_down_position.x
		while distance_y > grid_size:
			_held_down_position += Vector2(0, grid_size)
			distance_y = target_launch_position.y - _held_down_position.y
		while distance_y < -grid_size:
			_held_down_position -= Vector2(0, grid_size)
			distance_y = target_launch_position.y - _held_down_position.y
		target_launch_position = _held_down_position
		target_position_local = to_local(target_launch_position)
		if _held_down_position != _held_down_position_orig:
			_held_down_aim_changed = true
			
	raycast.target_position = target_position_local
	raycast.force_raycast_update()
	
	if (raycast.is_colliding()):
		target_launch_position = raycast.get_collision_point()
		target_position_local = to_local(target_launch_position)
	
	if target_position_local.length() < 10: 
		# same start and end point path not supported, add in slight offset
		# a delta that is too small causes the same issue
		target_launch_position = to_global(Vector2(0, 10))
		target_position_local = to_local(target_launch_position)
	
	var point_in_x = (target_position_local - $Path2D.curve.get_point_position(0)).x * -400/1152
	var point_in_y = min(-200, (target_position_local - $Path2D.curve.get_point_position(0)).y)
	$Path2D.curve.set_point_position(1, target_position_local)
	$Path2D.curve.set_point_in(1, Vector2(point_in_x, point_in_y))
	$Path2D.curve.set_point_out(0, Vector2(-point_in_x, point_in_y))
	points = $Path2D.curve.get_baked_points()
	
	$GridSprite.visible = _held_down
	$GridSprite.position = target_position_local
	
	if _held_down_aim_changed && !_held_down_visited_positions.has(_held_down_position):
		_held_down_visited_positions.append(_held_down_position)
		grid_aim_changed.emit()
	
	if Input.is_action_pressed("launch_color") && !_held_down:
		_held_down_time_count += delta
	if !Input.is_action_pressed("launch_color"):
		_held_down = false
		_held_down_time_count = 0.0
		_held_down_visited_positions = []
	if _held_down_time_count > 0.5 && !_held_down:
		_held_down_position = Vector2(0,0)
		_held_down = true
		_held_down_visited_positions = []


func get_aim_curve() -> Curve2D:
	return $Path2D.curve
