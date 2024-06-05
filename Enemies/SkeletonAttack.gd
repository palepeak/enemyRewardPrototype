class_name SkeletonAttack extends EnemyAttack

@export var player_tracker: PlayerTracker
@export var max_distance = 600
@export var shot_speed = 250
@export var bullet_scene: PackedScene = preload("res://EnemyUtils/EnemyBullet.tscn")


func try_attack() -> bool:
	var level = GameStateStore.get_level()
	var player = player_tracker.get_tracked_player()
	if !player:
		return false
	if !player_tracker.can_see_player():
		return false
	if max_distance > 0 && global_position.distance_to(player.global_position) > max_distance:
		return false
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.fire(global_position, (player.global_position - global_position).normalized(), shot_speed, 3000)
	level.add_child(bullet)
	return true
