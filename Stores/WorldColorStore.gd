extends Node

signal world_progress_update(progress)
const THREADED = true

var level_tile_map: TileMap = null
var color_image_map: Image = null
var image_compression_factor = 4
var color_texture: ImageTexture = null
var radius = 100

var total_size = 0
var progress_pixel = 0
var progress_percent = 0
var emitted_progress = 0

var threads = []
var requests = []
@onready var image_mutex: Mutex = Mutex.new()
@onready var threads_mutex: Mutex = Mutex.new()

const color_bit: Color = Color.WHITE

func set_world_state(level_map: TileMap):
	# Saving the current level mao
	level_tile_map = level_map
	
	# getting the bounding rect of the level map
	var level_map_bounding_cells = level_tile_map.get_used_rect()
	var level_size = 32 * (level_map_bounding_cells.size)
	var level_map_bounding = Rect2i(Vector2i(0,0), level_size)
	
	#creating the image
	color_image_map = Image.new().create(
		level_map_bounding.size.x / image_compression_factor,
		level_map_bounding.size.y / image_compression_factor,
		false,
		Image.FORMAT_L8
	)
	
	var unique_tiles = level_map.get_used_cells(0)
	var layer_count = level_map.get_layers_count()
	for layer in layer_count:
		if layer == 0:
			continue
		var new_tiles = level_tile_map.get_used_cells(layer)
		for tile in new_tiles:
			if !unique_tiles.has(tile):
				unique_tiles.append(tile)
	total_size = (unique_tiles.size()*32*32/image_compression_factor)/image_compression_factor
	print(unique_tiles.size())
	world_progress_update.emit(0)
			
	color_texture = ImageTexture.create_from_image(color_image_map)
	

func get_color_texture() -> Texture2D:
	return color_texture
	
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
	
func post_draw_color_line(start: Vector2i, end: Vector2i):
	requests.push_back([start, end])
		
func _thread_draw_color_function(start: Vector2i, end: Vector2i, radius: int, thread_ref):
	var visited = {}
	var to_visit = [start, end]
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
		var distance = distance_to(current_pixel, closest_point)
		# point too far, ignore
		if distance > radius:
			continue
		
		if THREADED:
			image_mutex.lock()
		if color_image_map.get_pixelv(current_pixel) != color_bit && _coord_on_tilemap_contains_tile(current_pixel):
			# draw pixel onto image
			color_image_map.set_pixelv(current_pixel, color_bit)
			progress_pixel += 1
			progress_percent = progress_pixel*100/total_size
			
			if THREADED:
				image_mutex.unlock()
			if (progress_percent != emitted_progress):
				print(str(progress_pixel) + "\t" + str(total_size))
				emitted_progress = progress_percent
				call_deferred("update_progress_percent", progress_percent)
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


func update_progress_percent(progress):
	if progress >= emitted_progress:
		world_progress_update.emit(progress)
		
func _coord_on_tilemap_contains_tile(position) -> bool:
	var tilemap_position = position
	tilemap_position *= image_compression_factor
	tilemap_position /= 32
	var layer_count = level_tile_map.get_layers_count()
	for layer in layer_count:
		if level_tile_map.get_cell_source_id(layer, tilemap_position) != -1:
			return true
	return false


func distance_to(point1: Vector2i, point2: Vector2i) -> int:
	return int(sqrt(pow((point2.y - point1.y), 2) + pow((point2.x - point1.x), 2)))
