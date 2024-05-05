class_name CharacterHealthManager extends Node

@export var max_health: int 
@export var death_sprite: Texture2D
@export var death_particle: PackedScene
@export var host_object: CharacterBody2D
@onready var current_health = max_health


func process_hit(_area: Area2D):
	var children = host_object.get_children()
	for child in children:
		if child is HitFlashSprite:
			child.play_hit_flash()
	current_health -= 1
	if current_health <= 0:
		process_death()


func process_death():
	var death_node = death_particle.instantiate() as GPUParticles2D
	(death_node.process_material as ShaderMaterial).set_shader_parameter("sprite", death_sprite)
	death_node.global_position = get_parent().global_position
	if host_object.velocity.x > 0:
		death_node.scale = Vector2(-1,1)
	get_tree().root.add_child(death_node)
	get_parent().queue_free()