class_name RoomState extends Object


var x: int
var y: int
var width: int
var height: int
var wall_height: int

enum RoomDirection {LEFT=0, RIGHT=1, TOP=2, BOTTOM=3}

func _init(
	x_arg: int,
	y_arg: int, 
	width_arg: int,
	height_arg: int, 
	wall_height_arg: int
):
	x = x_arg
	y = y_arg
	width = width_arg
	height = height_arg
	wall_height = wall_height_arg
	
func link_room_init(
	link_room: RoomState,
	direction: RoomDirection
):
	pass

func get_exits(direction: RoomDirection) -> Array[Vector2]:
	var exits: Array[Vector2] = []
	# get north south exits
	match direction:
		RoomDirection.LEFT:
			if height < 20:
				exits.append(Vector2(x, y+wall_height+(height/2.0)))
			else:
				exits.append(Vector2(x, y+wall_height+2.0))
				exits.append(Vector2(x, y+wall_height+height-4))
				
		RoomDirection.RIGHT:
			if height < 20:
				exits.append(Vector2(x+width+1, y+wall_height+(height/2.0)))
			else:
				exits.append(Vector2(x+width+1, y+wall_height+2.0))
				exits.append(Vector2(x+width+1, y+wall_height+height-4))
		RoomDirection.TOP:
			if width < 20:
				exits.append(Vector2(x+(width/2.0), y+wall_height-1))
			else:
				exits.append(Vector2(x+3, y+wall_height-1))
				exits.append(Vector2(x+width-2, y+wall_height-1))
		_:
			if width < 20:
				exits.append(Vector2(x+(width/2.0), y+wall_height+height))
			else:
				exits.append(Vector2(x+3, y+wall_height+height))
				exits.append(Vector2(x+width-2, y+wall_height+height))
	
	return exits
	
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
	
