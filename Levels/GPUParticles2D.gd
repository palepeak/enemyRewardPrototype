extends GPUParticles2D


func start_darkness(level_map: TileMap):
	var level_map_bounding_cells = level_map.get_used_rect()
	var level_size = 32 * (level_map_bounding_cells.size) / 2
	var shader = process_material as ShaderMaterial
	shader.set_shader_parameter("emission_box_extents", [level_size.x, level_size.y, 1])
	amount = 8000
