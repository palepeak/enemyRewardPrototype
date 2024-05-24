class_name EnemyHealthManager extends CharacterHealthManager

@onready var world_color_store: WorldColorStore = GameStateStore.get_level().get_world_color_store()
@export var drop_manager: EnemyDropManager

func process_hit(area: Area2D, damage: float):
	var world_color_store: WorldColorStore = GameStateStore.get_level().get_world_color_store()
	var on_color = world_color_store.global_coords_on_colored_tile(host_object.global_position)
	
	if invulnurable:
		hit_flash_sprite.play_hit_none_flash()
	elif on_color:
		super.process_hit(area, 2*damage)
		if drop_manager != null:
			drop_manager.process_hit(area, true)
	elif damage_on_shadow:
		super.process_hit(area, damage)
		if drop_manager != null:
			drop_manager.process_hit(area, false)
	else:
		hit_flash_sprite.play_hit_none_flash()

func process_death():
	var death_node = death_particle.instantiate() as GPUParticles2D
	death_node.process_material.set_shader_parameter("sprite", death_sprite)
	var texture_size = death_sprite.get_size() / 2.0
	death_node.process_material.set_shader_parameter("emission_box_extents", Vector3(
		texture_size.x, texture_size.y, 0.0
	))
	
	death_node.global_position = get_parent().global_position
	if hit_flash_sprite.flip_h:
		death_node.scale = Vector2(-1,1)
	GameStateStore.get_level().add_child(death_node)
	if death_audio != null:
		death_audio.reparent(death_node)
		death_audio.play()
	get_parent().queue_free()
