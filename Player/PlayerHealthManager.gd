class_name PlayerHealthManager extends CharacterHealthManager

@onready var player_instance: Player = get_parent()


func process_hit(area: Area2D, _damage: float = 1):
	super.process_hit(area, _damage)
	DebugStore.debug_print("player_hit")
	HudUiStore.player_health_changed.emit(current_health)


func process_death():
	if death_sprite == null:
		var animation_name = hit_flash_sprite.animation
		death_sprite = hit_flash_sprite.sprite_frames.get_frame_texture(animation_name, 0)
	
	PlayerStore.remove_player_ref(player_instance)
	GameStateStore.show_game_over_screen.emit()
	
	var death_node = death_particle.instantiate() as GPUParticles2D
	(death_node.process_material as ShaderMaterial).set_shader_parameter("sprite", death_sprite)
	death_node.global_position = player_instance.global_position
	GameStateStore.add_to_level(death_node)
