class_name EnemyDropManager extends Node2D

enum DropType {HIT, DEATH}
@export var type: DropType = DropType.DEATH

@export var requires_color: bool = true
@export var guarentee_first_drop: bool = true
@export_range(0, 1) var drop_chance: float
@export var min_drop_amount: int = 1
@export var max_drop_amount: int = 1
@export var drop_scene: PackedScene
@export var drop_chance_curve: Curve


func process_hit(area2d: Area2D):
	if type != DropType.HIT:
		return
	var level: Level = GameStateStore.get_level()
	if level == null:
		return
	if requires_color && !level.get_world_color_store().global_coords_on_colored_tile(global_position):
		return
	if randf() > drop_chance:
		return
	
	var drop_amount = int(drop_chance_curve.sample(randf()))
	for i in drop_amount:
		var drop = drop_scene.instantiate() as Node2D
		drop.global_rotation = area2d.global_rotation
		drop.global_position = global_position
		level.add_child.call_deferred(drop)

# Called when the node enters the scene tree for the first time.
func _exit_tree():
	if type != DropType.DEATH:
		return
	var level: Level = GameStateStore.get_level()
	if level != null:
		if !requires_color || level.get_world_color_store().global_coords_on_colored_tile(global_position):
			if randf() <= drop_chance || GameStateStore.get_first_drop(drop_scene.resource_path):
				var drop = drop_scene.instantiate()
				drop.global_position = global_position
				level.add_child.call_deferred(drop)
