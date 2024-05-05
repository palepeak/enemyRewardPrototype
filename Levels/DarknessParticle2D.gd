class_name DarknessParticle extends GPUParticles2D

@export var world_color_store: WorldColorStore


func _ready():
	world_color_store.world_color_progress_update.connect(on_world_color_progress_update)


func start_darkness(level_map: TileMap):
	var level_map_bounding_cells = level_map.get_used_rect()
	var level_size = 32 * (level_map_bounding_cells.size)
	
	var screen_size = Vector2i(get_viewport_rect().size)
	var emission_box_extents = level_size/2 + screen_size
	var shader = process_material as ShaderMaterial
	shader.set_shader_parameter("emission_box_extents", [emission_box_extents.x, emission_box_extents.y, 1])
	shader.set_shader_parameter("screen_size", screen_size)
	shader.set_shader_parameter("level_size", level_size)
	amount = level_size.x * level_size.y / 100


func on_world_color_progress_update(progress: int):
	if progress == 100:
		$AnimationPlayer.play("fade_out_permanent")
