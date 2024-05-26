class_name HallState extends Object

var start_room: RoomArea2D
var start: Vector2
var start_direction: RoomState.RoomDirection
var start_blocker: Vector2
var end_room: RoomArea2D
var end: Vector2
var end_direction: RoomState.RoomDirection
var end_blocker: Vector2
var wall_height: int

# Called when the node enters the scene tree for the first time.
func _init(
	start_room_arg: RoomArea2D,
	start_arg: Vector2, 
	end_room_arg: RoomArea2D,
	end_arg: Vector2, 
	wall_height_arg: int
):
	start_room = start_room_arg
	start = start_arg
	end_room = end_room_arg
	end = end_arg
	wall_height = wall_height_arg
	
	if start.x == end.x && start.y > end.y:
		start_direction = RoomState.RoomDirection.TOP
		end_direction = RoomState.RoomDirection.BOTTOM
		start_blocker = Vector2(start.x, start.y-2)
		end_blocker = Vector2(end.x, end.y+2)
	if start.x == end.x && start.y < end.y:
		start_direction = RoomState.RoomDirection.BOTTOM
		end_direction = RoomState.RoomDirection.TOP
		start_blocker = Vector2(start.x, start.y+2)
		end_blocker = Vector2(end.x, end.y-2)
	if start.x > end.x && start.y == end.y:
		start_direction = RoomState.RoomDirection.RIGHT
		end_direction = RoomState.RoomDirection.LEFT
		start_blocker = Vector2(start.x-2, start.y)
		end_blocker = Vector2(end.x+2, end.y)
	if start.x < end.x && start.y == end.y:
		start_direction = RoomState.RoomDirection.LEFT
		end_direction = RoomState.RoomDirection.RIGHT
		start_blocker = Vector2(start.x+2, start.y)
		end_blocker = Vector2(end.x-2, end.y)
