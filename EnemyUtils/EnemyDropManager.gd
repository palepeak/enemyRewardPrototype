class_name EnemyDropManager extends Node2D

@export var requires_color: bool = true
@export var guarentee_first_drop: bool = true
@export_range(0, 1) var drop_chance: float
@export var drop_scene: PackedScene

# Called when the node enters the scene tree for the first time.
func _exit_tree():
	var level: Level = GameStateStore.get_level()
	if level != null:
		var world_color_store: WorldColorStore = level.get_world_color_store()
		if !requires_color || world_color_store.global_coords_on_colored_tile(global_position):
			if randf() <= drop_chance || GameStateStore.get_first_drop(drop_scene.resource_path):
				var drop = drop_scene.instantiate()
				drop.global_position = global_position
				level.add_child.call_deferred(drop)
