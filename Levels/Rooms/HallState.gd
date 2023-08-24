class_name HallState extends Object

var start: Vector2
var end: Vector2
var wall_height: int

# Called when the node enters the scene tree for the first time.
func _init(start_arg: Vector2, end_arg: Vector2, wall_height_arg: int):
	start = start_arg
	end = end_arg
	wall_height = wall_height_arg
