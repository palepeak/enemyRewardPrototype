extends Node

var level_canvas_item: CanvasItem = null
var color_image_map: Image = null
var image_compression_factor = 2
var color_texture: ImageTexture = null

var threads = []
var requests = []
@onready var image_mutex: Mutex = Mutex.new()
@onready var threads_mutex: Mutex = Mutex.new()

const color_bit: Color = Color.WHITE

func set_world_state(level_map: TileMap):
	# Saving the current level mao
	level_canvas_item = level_map
	
	# getting the bounding rect of the level map
	var level_map_bounding_cells = level_canvas_item.get_used_rect() as Rect2i
	var level_size = 32 * (level_map_bounding_cells.size)
	var level_map_bounding = Rect2i(Vector2i(0,0), level_size)
	
	#creating the image
	color_image_map = Image.new().create(
		level_map_bounding.size.x / image_compression_factor,
		level_map_bounding.size.y / image_compression_factor,
		false,
		Image.FORMAT_L8
	)
			
	color_texture = ImageTexture.create_from_image(color_image_map)
	

func get_color_texture() -> Texture2D:
	return color_texture
	
func _process(_delta):
	if color_texture == null:
		return
	
	if !requests.is_empty():
		var request = requests.pop_back()
		_thread_draw_color_function(
			request[0]/image_compression_factor,
			request[1]/image_compression_factor, 
			10/image_compression_factor)
	
func post_draw_color_line(start: Vector2i, end: Vector2i):
	requests.push_back([start, end])
		
func _thread_draw_color_function(start: Vector2i, end: Vector2i, radius: int):
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
			
		# draw pixel onto image
		color_image_map.set_pixelv(current_pixel, color_bit)
		# add neighbors to visit list
		for x in range(current_pixel.x-1, current_pixel.x+2):
			for y in range(current_pixel.y-1, current_pixel.y+2):
				if (x == current_pixel.x and y == current_pixel.y):
					continue
				to_visit.append(Vector2i(x, y))
	
	# this call is thread safe without mutex
	color_texture.update(color_image_map)

func distance_to(point1: Vector2i, point2: Vector2i) -> int:
	return int(sqrt(pow((point2.y - point1.y), 2) + pow((point2.x - point1.x), 2)))
