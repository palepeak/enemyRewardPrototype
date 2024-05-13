class_name Bullet extends RigidBody2D

@export var smoke_scene: PackedScene
@export var fall_scene: PackedScene
var bullet_speed = 0
var bullet_direction = Vector2(0,0)
var bullet_range = 0
var bullet_start_pos: Vector2
var bullet_pierce = 0
var bullet_damage = 1.0
var bullet_force = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	contact_monitor = true
	max_contacts_reported = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bullet_range != 0:
		if global_position.distance_to(bullet_start_pos) > bullet_range:
			if fall_scene != null:
				var fall = fall_scene.instantiate() as GPUParticles2D
				fall.global_position = global_position
				fall.rotation = rotation
				
				GameStateStore.get_level().add_child(fall)
			queue_free()
	var collision_result = move_and_collide(bullet_direction * bullet_speed * delta)
	if collision_result != null:
		var other = collision_result.get_collider() as Node
		if other is TileMap:
			if smoke_scene != null:
				var smoke = smoke_scene.instantiate() as GPUParticles2D
				smoke.rotation = collision_result.get_normal().angle()
				smoke.global_position = collision_result.get_position()
				GameStateStore.get_level().add_child(smoke)
			queue_free()
		else:
			queue_free()
		pass
		
func fire(start_pos, direction: Vector2, speed, range_arg, pierce = 0):
	rotation = direction.angle()
	self.global_position = start_pos
	self.bullet_start_pos = start_pos
	self.bullet_speed = speed
	self.bullet_direction = direction
	self.bullet_range = range_arg
	self.bullet_pierce = pierce


func _on_enemy_hit(_area):
	if _area is EnemyHitbox && bullet_pierce >= 0:
		bullet_pierce -= 1
		_area.process_hit($DetectionArea, bullet_damage, bullet_force)
		queue_free()
	else:
		queue_free()
