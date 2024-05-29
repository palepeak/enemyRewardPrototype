class_name RoomState extends Object


# values are in grid values. 
#	eg. (x=10, y=20) == (global_position.x=320, global_position.y=640)
var x: int
var y: int
var width: int
var height: int
var wall_height: int
var custom_room: bool

var _used_exits: Array[Vector2]
var _exits: Array[Vector2]

enum RoomDirection {LEFT=0, RIGHT=1, TOP=2, BOTTOM=3}

func _init(
	x_arg: int,
	y_arg: int, 
	width_arg: int,
	height_arg: int, 
	wall_height_arg: int,
	custom_room_arg: bool = false,
):
	x = x_arg
	y = y_arg
	width = width_arg
	height = height_arg
	wall_height = wall_height_arg
	custom_room = custom_room_arg
	
	init_exits()
	
func mark_exit_used(exit: Vector2):
	_used_exits.append(exit)


func get_all_exits() -> Array[Vector2]:
	return _exits


func get_used_exits() -> Array[Vector2]:
	return _used_exits


func get_center() -> Vector2:
	return Vector2(
		x + width/2.0 + 1, 
		y + wall_height + height/2.0,
	)


func get_exits(direction: RoomDirection) -> Array[Vector2]:
	match direction:
		RoomDirection.LEFT:
			return _exits.filter(func(it) -> bool: return it.x == x)
		RoomDirection.RIGHT:
			return _exits.filter(func(it) -> bool: return it.x == x+width+1)
		RoomDirection.TOP:
			return _exits.filter(func(it) -> bool: return it.y == y+wall_height-1)
		_:
			return _exits.filter(func(it) -> bool: return it.y == y+wall_height+height)


func init_exits():
	_exits = []
	if height < 20:
		_exits.append(Vector2(x, y+wall_height+(height/2.0)))
		_exits.append(Vector2(x+width+1, y+wall_height+(height/2.0)))
	else:
		_exits.append(Vector2(x, y+wall_height+2.0))
		_exits.append(Vector2(x, y+wall_height+height-4))
		_exits.append(Vector2(x+width+1, y+wall_height+2.0))
		_exits.append(Vector2(x+width+1, y+wall_height+height-4))
	if width < 20:
		_exits.append(Vector2(x+(width/2.0), y+wall_height-1))
		_exits.append(Vector2(x+(width/2.0), y+wall_height+height))
	else:
		_exits.append(Vector2(x+3, y+wall_height-1))
		_exits.append(Vector2(x+width-2, y+wall_height-1))
		_exits.append(Vector2(x+3, y+wall_height+height))
		_exits.append(Vector2(x+width-2, y+wall_height+height))


func get_room_direction_inverse(direction: RoomDirection) -> RoomDirection:
	match direction:
		RoomDirection.LEFT:
			return RoomDirection.RIGHT
		RoomDirection.RIGHT:
			return RoomDirection.LEFT
		RoomDirection.TOP:
			return RoomDirection.BOTTOM
		_:
			return RoomDirection.TOP
	
