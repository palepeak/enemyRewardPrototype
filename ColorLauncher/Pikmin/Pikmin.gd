class_name Pikmin extends CharacterBody2D

var in_party = false
var party_moving = false
var _party_target_pos


func _physics_process(delta):
	global_rotation = 0
	if !in_party:
		var player = $PlayerTracker.get_nearest_player(global_position)
		if player != null && player.can_collect_pikmin():
			var target_pos: Vector2 = player.global_position
			velocity = (target_pos - global_position).normalized() * 100
			if velocity != Vector2.ZERO || party_moving:
				$Pikmin.play("walk")
			else:
				$Pikmin.play("default")
			$Pikmin.flip_h = velocity.x < 0

			move_and_slide()
		else:
			$Pikmin.play("default")
	else:
		if _party_target_pos != null && global_position.distance_to(_party_target_pos) > 10:
			velocity = (_party_target_pos - global_position).normalized() * 300
			move_and_slide()


func _on_area_2d_area_entered(area):
	if area is PlayerHitbox && !in_party && area.can_collect_pikmin():
		area.collect_pikmin(self)
		velocity = Vector2.ZERO
		in_party = true


func set_party_velocity(movement: PikminHolder.PartyMovement):
	if movement == PikminHolder.PartyMovement.LEFT:
		$Pikmin.play("walk")
		$Pikmin.flip_h = true
	if movement == PikminHolder.PartyMovement.RIGHT:
		$Pikmin.play("walk")
		$Pikmin.flip_h = false
	if movement == PikminHolder.PartyMovement.IDLE:
		$Pikmin.play("default")
		$Pikmin.flip_h = false


func set_party_target_pos(target):
	_party_target_pos = target
