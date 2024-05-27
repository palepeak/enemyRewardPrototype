class_name RoomCreator extends Node

const DEBUG = false

const ROOMS_LAYER = 0
const WALLS_LAYER = 1
const WALLS_0_LAYER = 2
const FURNITURE_LAYER = 3
const DEBUG_LAYER = 3

const WALL_TERRAIN_ID = 0
const FLOOR_TERRAIN_ID = 1

const SOURCE_ID = 0

var _room_area_scene = preload("res://Levels/Rooms/RoomArea2D.tscn")
var _treasure_scene = preload("res://Drops/TreasureChest.tscn")
var _temp_shotgun_scene = preload("res://Weapons/shotgun/Shotgun.tscn")


func create_treasure_room(
	room_state: RoomState,
	tilemap: TileMap,
	level_root: Level,
) -> RoomArea2D:
	var room_area = create_room(room_state, tilemap, level_root)
	var treasure_chest = _treasure_scene.instantiate() as TreasureChest
	treasure_chest.reward = _temp_shotgun_scene
	treasure_chest.position = 32 * Vector2(
		room_state.width / 2, 
		room_state.height / 2
	)
	treasure_chest.world_color_store = level_root.get_world_color_store()
	room_area.add_child.call_deferred(treasure_chest)
	return room_area

func create_room(
	room_state: RoomState,
	tilemap: TileMap,
	level_root: Node2D,
) -> RoomArea2D:
	set_up_layers(tilemap)
	draw_border_and_back_wall(
		room_state.x, room_state.y, 
		room_state.width, room_state.height, room_state.wall_height, 
		tilemap
	)
	var return_val = create_area(
		room_state,
		level_root,
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
	return return_val

func create_hall(
	hall_state: HallState, 
	tilemap: TileMap
):
	# hall is horizontal
	if hall_state.start.y == hall_state.end.y:
		create_horizontal_hall(hall_state, tilemap)
	elif hall_state.start.x == hall_state.end.x:
		create_vertical_hall(hall_state, tilemap)


func create_horizontal_hall(hall_state: HallState, tilemap: TileMap):
	hall_state.start_room.mark_exit_used(
		hall_state.start_blocker,
		hall_state.start_direction,
		hall_state.end_room,
	)
	hall_state.end_room.mark_exit_used(
		hall_state.end_blocker, 
		hall_state.end_direction,
		hall_state.start_room,
	)
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
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-hall_state.wall_height), SOURCE_ID, Vector2(4, 1))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-1), SOURCE_ID, Vector2(0, 1))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-hall_state.wall_height), SOURCE_ID, Vector2(6, 1))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-1), SOURCE_ID, Vector2(2, 1))
	var wall_cells = []
	for n in range(hall_state.start.x, hall_state.end.x+1):
		for m in hall_state.wall_height:
			wall_cells.append(Vector2(n, hall_state.start.y-1-m))
	tilemap.set_cells_terrain_connect(WALLS_LAYER, wall_cells, 0, WALL_TERRAIN_ID)
	# replacing end tiles manually
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x, hall_state.start.y-hall_state.wall_height), SOURCE_ID, Vector2(4, 1))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.end.x, hall_state.end.y-hall_state.wall_height), SOURCE_ID, Vector2(6, 1))
	for x in range(hall_state.start.x+1, hall_state.end.x):
		tilemap.set_cell(
			WALLS_LAYER, 
			Vector2(x, hall_state.start.y-hall_state.wall_height), 
			SOURCE_ID, 
			Vector2(5, 1),
		)
	# Move wall height 0 to layer
	for i in range(hall_state.start.x, hall_state.end.x+1):
		var coords = Vector2(i, hall_state.start.y-1)
		var tile = tilemap.get_cell_atlas_coords(WALLS_LAYER, coords)
		tilemap.set_cell(WALLS_0_LAYER, coords, SOURCE_ID, tile)
		tilemap.erase_cell(WALLS_LAYER, coords)


func create_vertical_hall(hall_state: HallState, tilemap: TileMap):
	hall_state.start_room.mark_exit_used(
		hall_state.start_blocker,
		hall_state.start_direction,
		hall_state.end_room,
	)
	hall_state.end_room.mark_exit_used(
		hall_state.end_blocker, 
		hall_state.end_direction,
		hall_state.start_room,
	)
	
	var smaller = min(hall_state.start.y, hall_state.end.y+1)
	var larger = max(hall_state.start.y, hall_state.end.y+1)
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x, larger+1), SOURCE_ID, Vector2(5, 2))
	tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x+1, larger+1), SOURCE_ID, Vector2(4, 3))
	for i in range(smaller-1, larger+1):
		# draw the path itself
		tilemap.erase_cell(WALLS_LAYER, Vector2(hall_state.start.x, i))
		tilemap.erase_cell(WALLS_0_LAYER, Vector2(hall_state.start.x, i))
		tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x, i), SOURCE_ID, Vector2(3, 3))
		tilemap.erase_cell(WALLS_LAYER, Vector2(hall_state.start.x + 1, i))
		tilemap.erase_cell(WALLS_0_LAYER, Vector2(hall_state.start.x + 1, i))
		tilemap.set_cell(ROOMS_LAYER, Vector2(hall_state.start.x + 1, i), SOURCE_ID, Vector2(4, 3))
		
		# drawing left wall
		tilemap.erase_cell(ROOMS_LAYER, Vector2(hall_state.start.x-1, i))
		tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x-1, i), SOURCE_ID, Vector2(0, 4))
		# drawing right wall
		tilemap.erase_cell(ROOMS_LAYER, Vector2(hall_state.start.x+2, i))
		tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x+2, i), SOURCE_ID, Vector2(2, 4))
	
	# set up top tiles
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x+2, smaller-1), SOURCE_ID, Vector2(3, 6))
	tilemap.set_cell(WALLS_LAYER, Vector2(hall_state.start.x-1, smaller-1), SOURCE_ID, Vector2(2, 6))
	# set up bottom wall tiles
	for y in range(larger-hall_state.wall_height+1, larger+1):
		var left_tile = Vector2(6, 0)
		var right_tile = Vector2(4, 0)
		var layer = WALLS_LAYER
		if y == larger-hall_state.wall_height+1:
			left_tile = Vector2(6, 1)
			right_tile = Vector2(4, 1)
		elif y == larger:
			tilemap.erase_cell(layer, Vector2(hall_state.start.x-1, y))
			tilemap.erase_cell(layer, Vector2(hall_state.start.x+2, y))
			layer = WALLS_0_LAYER
			left_tile = Vector2(2, 1)
			right_tile = Vector2(0, 1)
		
		tilemap.set_cell(layer, Vector2(hall_state.start.x-1, y), SOURCE_ID, left_tile)
		tilemap.set_cell(layer, Vector2(hall_state.start.x+2, y), SOURCE_ID, right_tile)


func set_up_layers(tilemap: TileMap):
	while tilemap.get_layers_count() < 5:
		tilemap.add_layer(-1)
	tilemap.set_layer_z_index(WALLS_LAYER, 100)
	tilemap.set_layer_z_index(WALLS_0_LAYER, 100)
	tilemap.set_layer_z_index(DEBUG_LAYER, 1000)
	
func draw_border_and_back_wall(
	x: int,
	y: int,
	width: int,
	height: int,
	wall_height: int,
	tilemap: TileMap,
): 
	# drawing left and right wall
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
	tilemap.set_cell(WALLS_LAYER, Vector2(x+1, y), SOURCE_ID, Vector2(0, 0))
	tilemap.set_cell(WALLS_LAYER, Vector2(x+1, y+wall_height-1), SOURCE_ID, Vector2(0, 1))
	tilemap.set_cell(WALLS_LAYER, Vector2(x+width, y), SOURCE_ID, Vector2(2, 0))
	tilemap.set_cell(WALLS_LAYER, Vector2(x+width, y+wall_height-1), SOURCE_ID, Vector2(2, 1))
	var wall_cells = []
	for n in width:
		for m in wall_height:
			wall_cells.append(Vector2(x+n+1, y+m))
	tilemap.set_cells_terrain_connect(WALLS_LAYER, wall_cells, 0, WALL_TERRAIN_ID)
	
	# Move wall height 0 to layer
	for i in range(x+1, x+width+1):
		var coords = Vector2(i, y+wall_height-1)
		var tile = tilemap.get_cell_atlas_coords(WALLS_LAYER, coords)
		tilemap.set_cell(WALLS_0_LAYER, coords, SOURCE_ID, tile)
		tilemap.erase_cell(WALLS_LAYER, coords)


func create_area(
	room_state: RoomState,
	level_root: Node2D,
) -> RoomArea2D:
	var area2d = _room_area_scene.instantiate() as RoomArea2D
	area2d.set_room_state(room_state)
	level_root.add_child(area2d)
	return area2d

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


func place_boss_room(exit: Vector2, level_map: TileMap, boss_room_ref: BossRoom):
	for layer in range(0, 4):
		level_map.erase_cell(layer, exit + Vector2(0, 1))
		level_map.erase_cell(layer, exit + Vector2(-1, 1))
		level_map.erase_cell(layer, exit + Vector2(0, 0))
		level_map.erase_cell(layer, exit + Vector2(-1, 0))
		level_map.erase_cell(layer, exit + Vector2(0, -1))
		level_map.erase_cell(layer, exit + Vector2(-1, -1))
		level_map.erase_cell(layer, exit + Vector2(0, -2))
		level_map.erase_cell(layer, exit + Vector2(-1, -2))
	boss_room_ref.global_position = exit * 32
	boss_room_ref.z_index = level_map.z_index+1
