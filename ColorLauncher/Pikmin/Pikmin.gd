class_name Pikmin extends CharacterBody2D

var active = true
var in_party = false
var _party_target_pos
var _phasing = false
var _phase_target: Vector2
@onready var sprite: AnimatedSprite2D = $Sprite


func _physics_process(delta):
	global_rotation = 0
	sprite.visible = active
	if !active:
		return
	
	if !in_party:
		var player = $PlayerTracker.get_nearest_player(global_position)
		if player != null && player.can_collect_pikmin():
			var target_pos: Vector2 = player.global_position
			velocity = (target_pos - global_position).normalized() * 100
			if velocity != Vector2.ZERO:
				sprite.play("walk")
			else:
				sprite.play("default")
			sprite.flip_h = velocity.x < 0

			global_position += velocity * delta
		else:
			sprite.play("default")
	elif _phasing:
		velocity = (_phase_target - global_position).normalized() * 300
		global_position += velocity * delta
		if global_position.distance_to(_phase_target) <= 10:
			_phasing = false
	else:
		if _party_target_pos != null && global_position.distance_to(_party_target_pos) > 10:
			velocity = (_party_target_pos - global_position).normalized() * 300
			move_and_slide()


func _on_area_2d_area_entered(area):
	if active && area is PlayerHitbox && !in_party && area.can_collect_pikmin():
		area.collect_pikmin(self)
		velocity = Vector2.ZERO
		in_party = true
		
		$Area2D.set_deferred("monitoring", false)


func phase_to(target: Vector2):
	_phasing = true
	_phase_target = target

func set_party_velocity(movement: PikminHolder.PartyMovement):
	if movement == PikminHolder.PartyMovement.LEFT:
		sprite.play("walk")
		sprite.flip_h = true
	if movement == PikminHolder.PartyMovement.RIGHT:
		sprite.play("walk")
		sprite.flip_h = false
	if movement == PikminHolder.PartyMovement.IDLE:
		sprite.play("default")
		sprite.flip_h = false


func set_party_target_pos(target):
	_party_target_pos = target


func remove_from_party():
	$Area2D.set_deferred("monitoring", true)
	active = false
	in_party = false
