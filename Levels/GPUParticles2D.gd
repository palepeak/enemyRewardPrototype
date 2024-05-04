extends GPUParticles2D


func start_darkness(level_map: TileMap):
	var level_map_bounding_cells = level_map.get_used_rect()
	var level_size = 32 * (level_map_bounding_cells.size)
	
	var screen_size = Vector2i(get_viewport_rect().size)
	var emission_box_extents = level_size/2 + screen_size
	var shader = process_material as ShaderMaterial
	shader.set_shader_parameter("emission_box_extents", [emission_box_extents.x, emission_box_extents.y, 1])
	shader.set_shader_parameter("screen_size", screen_size)
	shader.set_shader_parameter("level_size", level_size)
	amount = 12000
