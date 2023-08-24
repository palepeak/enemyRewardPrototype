class_name RoomCreator extends Node

const DEBUG = false

const ROOMS_LAYER = 0
const WALLS_LAYER = 1
const FURNITURE_LAYER = 2
const DEBUG_LAYER = 2

const WALL_TERRAIN_ID = 0
const FLOOR_TERRAIN_ID = 1

const SOURCE_ID = 0

# Called when the node enters the scene tree for the first time.
func create_room(
	room_state: RoomState,
	tilemap: TileMap
):
	set_up_layers(tilemap)
	draw_boarder_and_back_wall(
		room_state.x, room_state.y, 
		room_state.width, room_state.height, room_state.wall_height, 
		tilemap
	)
	draw_floor(
		room_state.x, room_state.y, 
		room_state.width, room_state.height, room_state.wall_height, 
		tilemap
	)
	if DEBUG:
		for direction in RoomState.RoomDirection.values():
			var exits = room_state.get_exits(direction)
			for exit in exits:
				tilemap.set_cell(DEBUG_LAYER, exit, SOURCE_ID, Vector2(1, 2))

func create_hall(hall_state: HallState, tilemap: TileMap):
	# hall is horizontal
	if hall_state.start.y == hall_state.end.y:
		create_horizontal_hall(hall_state, tilemap)
		
		
func create_horizontal_hall(hall_state: HallState, tilemap: TileMap):
	for i in range(hall_state.start.x, hall_state.end.x+1):
		# draw the path itself
		tilemap.erase_cell(WALLS_LAYER, Vector2(i, hall_state.start.y))
		tilemap.set_cell(ROOMS_LAYER, Vector2(i, hall_state.start.y), SOURCE_ID, Vector2(4, 2))
		tilemap.erase_cell(WALLS_LAYER, Vector2(i, hall_state.start.y+1))
		tilemap.set_cell(ROOMS_LAYER, Vector2(i, hall_state.start.y+1), SOURCE_ID, Vector2(4, 3))
		# draw the bottom border
		tilemap.set_cell(WALLS_LAYER, Vector2(i, hall_state.start.y+2), SOURCE_ID, Vector2(1, 3))
	
	# draw the two bottom corner pieces
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x, hall_state.start.y+2), SOURCE_ID, Vector2(3, 6))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.end.x, hall_state.start.y+2), SOURCE_ID, Vector2(2, 6))
	#draw shadow at exit
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.end.x+1, hall_state.end.y), SOURCE_ID, Vector2(5, 2))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.end.x+1, hall_state.end.y+1), SOURCE_ID, Vector2(4, 3))
	# drawing the back wall
	for i in hall_state.wall_height:
		tilemap.erase_cell(WALLS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-1-i))
		tilemap.erase_cell(WALLS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-1-i))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-hall_state.wall_height), SOURCE_ID, Vector2(0, 0))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-1), SOURCE_ID, Vector2(0, 1))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-hall_state.wall_height), SOURCE_ID, Vector2(2, 0))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-1), SOURCE_ID, Vector2(2, 1))
	var wall_cells = []
	for n in range(hall_state.start.x, hall_state.end.x+1):
		for m in hall_state.wall_height:
			wall_cells.append(Vector2(n, hall_state.start.y-1-m))
	tilemap.set_cells_terrain_connect(ROOMS_LAYER, wall_cells, 0, WALL_TERRAIN_ID)
	


func set_up_layers(tilemap: TileMap):
	while tilemap.get_layers_count() < 4:
		tilemap.add_layer(-1)
	tilemap.set_layer_z_index(WALLS_LAYER, 100)
	tilemap.set_layer_z_index(DEBUG_LAYER, 1000)
	
func draw_boarder_and_back_wall(
	x: int,
	y: int,
	width: int,
	height: int,
	wall_height: int,
	tilemap: TileMap,
): 
	# drawing left and wall
	tilemap.set_cell(WALLS_LAYER, Vector2(x, y), SOURCE_ID, Vector2(0, 3))
	tilemap.set_cell(WALLS_LAYER, Vector2(x+width+1, y), SOURCE_ID, Vector2(2, 3))
	for i in height + wall_height - 1:
		tilemap.set_cell(WALLS_LAYER, Vector2(x, y+i+1), SOURCE_ID, Vector2(0, 4))
		tilemap.set_cell(WALLS_LAYER, Vector2(x+width+1,y+i+1), SOURCE_ID, Vector2(2, 4))
		
	# drawing bottom border
	var bottom_border_y = y+height+wall_height
	tilemap.set_cell(WALLS_LAYER, Vector2(x,bottom_border_y), SOURCE_ID, Vector2(0, 5))
	tilemap.set_cell(WALLS_LAYER, Vector2(x+width+1,bottom_border_y), SOURCE_ID, Vector2(2, 5))
	for i in width:
		tilemap.set_cell(WALLS_LAYER, Vector2(x+i+1,bottom_border_y), SOURCE_ID, Vector2(1, 5))
		
	# drawing the back wall
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+1, y), SOURCE_ID, Vector2(0, 0))
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+1, y+wall_height-1), SOURCE_ID, Vector2(0, 1))
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+width, y), SOURCE_ID, Vector2(2, 0))
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+width, y+wall_height-1), SOURCE_ID, Vector2(2, 1))
	var wall_cells = []
	for n in width:
		for m in wall_height:
			wall_cells.append(Vector2(x+n+1, y+m))
	tilemap.set_cells_terrain_connect(ROOMS_LAYER, wall_cells, 0, WALL_TERRAIN_ID)

func draw_floor(
	x: int,
	y: int,
	width: int,
	height: int,
	wall_height: int, 
	tilemap: TileMap
):
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+1, y+wall_height), SOURCE_ID, Vector2(3, 2))
	tilemap.set_cell(ROOMS_LAYER, Vector2(x+width, y+height+wall_height-1), SOURCE_ID, Vector2(4, 2))
	var floor_cells = []
	for n in width:
		for m in height:
			floor_cells.append(Vector2(x+n+1, y+m+wall_height))
	tilemap.set_cells_terrain_connect(ROOMS_LAYER, floor_cells, 0, FLOOR_TERRAIN_ID, false)
	
