extends Node

var level_canvas_item: CanvasItem = null
var color_texture: ImageTexture = null

const color_bit: Color = Color.WHITE

func set_world_state(level_map: TileMap):
	# Saving the current level mao
	level_canvas_item = level_map
	
	# getting the bounding rect of the level map
	var level_map_bounding_cells = level_canvas_item.get_used_rect() as Rect2i
	var level_size = 32 * (level_map_bounding_cells.size)
	var level_map_bounding = Rect2i(Vector2i(0,0), level_size)
	
	#creating the image
	var image = Image.new().create(
		level_map_bounding.size.x,
		level_map_bounding.size.y,
		false,
		Image.FORMAT_L8
	)
	for i in level_map_bounding.size.x:
		for n in 50:
			image.set_pixel(i, n, color_bit)
			
	color_texture = ImageTexture.create_from_image(image)
	

func get_color_texture() -> Texture2D:
	return color_texture
