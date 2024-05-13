extends CharacterBody2D

@onready var world_color_store: WorldColorStore = GameStateStore.get_level().get_world_color_store()


func _process(_delta):
	$HitFlashAnimatedSprite2d.set_light_shimmer(
		world_color_store.global_coords_on_colored_tile(global_position)
	)
