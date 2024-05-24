class_name WorldColorStore extends Node

signal world_color_progress_update(progress: int)

const THREADED = true

var level_tile_map: TileMap = null
var boss_tile_map: TileMap = null
var boss_tile_map_position = null
var color_image_map: Image = null
var image_compression_factor = 4
var color_texture: ImageTexture = null
var radius = 100

var total_size = 0
var progress_pixel = 0
var progress_percent: int = 0.0
var emitted_progress: int = 0.0

var threads = []
var requests = []
@onready var image_mutex: Mutex = Mutex.new()
@onready var threads_mutex: Mutex = Mutex.new()

const color_bit: Color = Color.WHITE
const colorable_bit: Color = Color.GRAY


func set_world_state(level_map: TileMap, boss_map: TileMap):
	# Saving the current level mao
	level_tile_map = level_map
	boss_tile_map = boss_map
	boss_tile_map_position = boss_tile_map.global_position
	
	# getting the bounding rect of the level map
	var level_map_bounding_cells = level_tile_map.get_used_rect()
	var level_size = 32 * (level_map_bounding_cells.size)
	var level_map_bounding = Rect2i(Vector2i(0,0), level_size)
	
	#creating the image
	color_image_map = Image.create(
		level_map_bounding.size.x / image_compression_factor,
		level_map_bounding.size.y / image_compression_factor,
		false,
		Image.FORMAT_L8
	)
	for x in color_image_map.get_size().x:
		for y in color_image_map.get_size().y:
			if (_coord_on_tilemap_contains_scoring_tile(Vector2i(x, y))):
				color_image_map.set_pixel(x, y, colorable_bit)
	
	var scoring_tiles = level_map.get_used_cells(0)
	total_size = scoring_tiles.size()*32*32
			
	color_texture = ImageTexture.create_from_image(color_image_map)
	HudUiStore.world_progress_update.emit(0, color_texture)


func get_color_texture() -> Texture2D:
	return color_texture


func post_draw_color_line(start: Vector2i, end: Vector2i):
	requests.push_back([start, end])


func _process(_delta):
	if color_texture == null:
		return
	
	if THREADED:
		threads_mutex.lock()
		if threads.size() < 10 and !requests.is_empty():
			var request = requests.pop_back()
			var thread = Thread.new()
			threads.push_back(thread)
			thread.start(_thread_draw_color_function.bind(
				request[0]/image_compression_factor,
				request[1]/image_compression_factor, 
				radius/image_compression_factor,
				thread))
		threads_mutex.unlock()
	else:
		if !requests.is_empty():
			var request = requests.pop_back()
			_thread_draw_color_function(
				request[0]/image_compression_factor,
				request[1]/image_compression_factor, 
				radius/image_compression_factor,
				null)


func _thread_draw_color_function(
	start: Vector2i, 
	end: Vector2i, 
	radius_compressed: int, 
	thread_ref,
):
	var visited = {}
	var to_visit = [end, start]
	while !to_visit.is_empty():
		# get current pixel to work with
		var current_pixel = to_visit.pop_back() as Vector2i
		# check if its already been visited
		if visited.has(current_pixel):
			continue
		# check if pixel is within bounds
		if current_pixel.x < 0 or current_pixel.x >= color_image_map.get_width() or current_pixel.y < 0 or current_pixel.y >= color_image_map.get_height():
			continue
		visited[current_pixel] = true
		
		# process current pixel is in bounds
		# getting the closest pixel along the slope
		var closest_point = Vector2i(Geometry2D.get_closest_point_to_segment(
			current_pixel,
			start,
			end
		))
		if start == end:
			closest_point = start
		# checking distance
		var distance = _distance_to(current_pixel, closest_point)
		# point too far, ignore
		if distance > radius_compressed:
			continue
		
		if THREADED:
			image_mutex.lock()
		if color_image_map.get_pixelv(current_pixel) != color_bit && _coord_on_tilemap_contains_tile(current_pixel):
			# draw pixel onto image
			color_image_map.set_pixelv(current_pixel, color_bit)
			if _coord_on_tilemap_contains_scoring_tile(current_pixel):
				progress_pixel += image_compression_factor * image_compression_factor
			progress_percent = progress_pixel*100/total_size
			
			if THREADED:
				image_mutex.unlock()
			if (progress_percent != emitted_progress):
				emitted_progress = progress_percent
				call_deferred("_update_progress_percent", progress_percent)
		elif THREADED:
			image_mutex.unlock()
			
		
		# add neighbors to visit list
		for x in range(current_pixel.x-1, current_pixel.x+2):
			for y in range(current_pixel.y-1, current_pixel.y+2):
				if (x != current_pixel.x || y != current_pixel.y):
					to_visit.append(Vector2i(x, y))
				
	if THREADED:
		# this call is thread safe without mutex
		color_texture.call_deferred("update", color_image_map)
		threads_mutex.lock()
		threads.erase(thread_ref)
		threads_mutex.unlock()
	else:
		color_texture.update(color_image_map)


func _update_progress_percent(progress):
	if progress >= emitted_progress:
		HudUiStore.world_progress_update.emit(progress, color_texture)
		world_color_progress_update.emit(progress)


# Only layer 0 is used for scoring
func _coord_on_tilemap_contains_scoring_tile(position) -> bool:
	var tilemap_position = position
	tilemap_position *= image_compression_factor
	# Not offsetting since the offset only affects top of walls
	# which is not counted for scoring anyways
	# tilemap_position += Vector2i(0, image_compression_factor)
	tilemap_position /= 32
	return level_tile_map.get_cell_source_id(0, tilemap_position) != -1


func _coord_on_tilemap_contains_tile(position: Vector2i) -> bool:
	var tilemap_position = position
	tilemap_position *= image_compression_factor
	# adjusting by the image_compression_factor since int division
	# trims the decimal. Not doing this might result in off by 1.
	tilemap_position += Vector2i(0, image_compression_factor)
	tilemap_position /= 32
	
	var boss_map_position = position
	boss_map_position *= image_compression_factor
	boss_map_position -= Vector2i(boss_tile_map_position)
	boss_map_position /= 32
	for layer in level_tile_map.get_layers_count():
		var result = level_tile_map.get_cell_source_id(layer, tilemap_position) != -1
		if result:
			return true
	for layer in boss_tile_map.get_layers_count():
		var result = boss_tile_map.get_cell_source_id(layer, boss_map_position) != -1
		if result:
			return true
	return false


func global_coords_on_colored_tile(coords: Vector2) -> bool:
	coords = coords / image_compression_factor
	# coords outside of map
	if coords.x < 0 || coords.y < 0:
		return false
	var image_size = color_image_map.get_size()
	if coords.x >= image_size.x || coords.y >= image_size.y:
		return false
	return color_image_map.get_pixelv(coords) == color_bit


func _distance_to(point1: Vector2i, point2: Vector2i) -> int:
	return int(sqrt(pow((point2.y - point1.y), 2) + pow((point2.x - point1.x), 2)))
