class_name CharacterHealthManager extends Node2D

@export var max_health: int 
@export var damage_on_shadow = true
@export var invulnurable: bool = false
@export var death_sprite: Texture2D
@export var death_particle: PackedScene = preload("res://EnemyUtils/EnemyDeathParticle.tscn")
@export var host_object: Node2D
@export var death_audio: AudioStreamPlayer2D
@export var hit_flash_sprite: HitFlashSprite

@onready var current_health = max_health


func process_hit(_area: Area2D, damage: float):
	hit_flash_sprite.play_hit_flash()
	current_health -= damage
	if current_health <= 0:
		process_death()


func process_death():
	if death_sprite == null:
		var animation_name = hit_flash_sprite.animation
		death_sprite = hit_flash_sprite.sprite_frames.get_frame_texture(animation_name, 0)
	var death_node = death_particle.instantiate() as GPUParticles2D
	(death_node.process_material as ShaderMaterial).set_shader_parameter("sprite", death_sprite)
	death_node.global_position = get_parent().global_position
	if host_object.velocity.x > 0:
		death_node.scale = Vector2(-1,1)
	GameStateStore.add_to_level(death_node)
	death_audio.autoplay = true
	death_audio.reparent(death_node)
	get_parent().queue_free()
