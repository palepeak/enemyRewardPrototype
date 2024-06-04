class_name Player extends CharacterBody2D

# Exports
@export var gun_scene: PackedScene
@export var dead: bool = false

# Global

# Local
@onready var sprite: HitFlashSprite = $HitFlashSprite
var gun: Node2D
var _gun_controller: BasicShootable
var is_left_hand = false
var gun_one_handed = true
var gun_position = 0.0
var pikmin_holder: PikminHolder

# Called when the node enters the scene tree for the first time.
func _ready():
	motion_mode = MOTION_MODE_FLOATING
	sprite.play("idle_down")
	sprite.z_index = z_index
	
	if gun_scene != null:
		add_gun(gun_scene.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$TerrainHitbox.disabled = DebugStore.debug_mode
	if dead:
		return
	
	var direction = get_aim_position_rotation()
	if not is_left_hand and (direction > 2 * PI/3 or direction < -2 * PI/3):
		# switch to left hand
		is_left_hand = true
		gun.scale = Vector2(-1,1)
		$HitFlashSprite/GunLine/GunPosition.progress_ratio = gun_position
		gun.position = $HitFlashSprite/GunLine/GunPosition.position
		$HitFlashSprite/other_hand.position = $HitFlashSprite/RightHand.position
	elif is_left_hand and (direction > -PI/3 and direction < 1 * PI/3):
		# switch to right hand
		is_left_hand = false
		gun.scale = Vector2(1,1)
		$HitFlashSprite/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
		gun.position = $HitFlashSprite/GunLine/GunPosition.position
		$HitFlashSprite/other_hand.position = $HitFlashSprite/LeftHand.position
	
	if gun != null:
		gun.rotation = get_gun_rotation(is_left_hand)
		gun.z_index = z_index+1
	
	var moving = velocity != Vector2.ZERO
	# Setting moving animation
	if direction > PI/4 and direction <= 3 * PI/4:
		$HitFlashSprite/other_hand.visible = true
		if sprite.is_playing():
			if moving:
				sprite.play("walk_down")
			else:
				sprite.play("idle_down")
	elif direction > -PI/4 and direction <= PI/4:
		$HitFlashSprite/other_hand.visible = false
		if sprite.is_playing():
			if moving:
				sprite.play("walk_right")
			else:
				sprite.play("idle_right")
	elif direction > -3 * PI/4 and direction <= -PI/4:
		$HitFlashSprite/other_hand.visible = true
		gun.z_index = z_index-1
		if sprite.is_playing():
			if moving:
				sprite.play("walk_up")
			else:
				sprite.play("idle_up")
	else:
		$HitFlashSprite/other_hand.visible = false
		if sprite.is_playing():
			if moving:
				sprite.play("walk_left")
			else:
				sprite.play("idle_left")


func add_gun(new_gun: Node2D):
	if gun != null:
		remove_child(gun)
		gun = null
	
	gun = new_gun
	_gun_controller = gun.find_children("*", "BasicShootable")[0]
	var gun_positioner = gun.find_children("*", "GunPositioner")
	if gun_positioner.size() > 0:
		gun_position = (gun_positioner[0] as GunPositioner).position
		gun_one_handed = (gun_positioner[0] as GunPositioner).one_handed
	$HitFlashSprite/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
	gun.position = $HitFlashSprite/GunLine/GunPosition.position
	if gun_one_handed == true or gun_one_handed == null:
		$HitFlashSprite/other_hand.visible = true
		if is_left_hand:
			$HitFlashSprite/other_hand.position = $HitFlashSprite/RightHand.position
		else:
			$HitFlashSprite/other_hand.position = $HitFlashSprite/LeftHand.position
	else:
		$HitFlashSprite/other_hand.visible = false
	if gun.get_parent() != null:
		gun.reparent(self, false)
	else:
		add_child(gun)
		
	if gun.has_method("on_pickup"):
		gun.on_pickup()
		$CollectRewardAudioPlayer.play()


func remove_gun():
	if gun != null:
		remove_child(gun)
		gun = null


func set_gun_enabled(enabled: bool):
	_gun_controller.enabled = enabled


func get_aim_position_rotation() -> float:
	return (ControlsManager.get_aim_target_local(self, 300)).normalized().angle()


func get_gun_rotation(is_flipped) -> float:
	var opposite = gun.opposite
	var hypotnuse = ControlsManager.get_aim_target_global(self, 300).distance_to(gun.global_position)
	var base_rotation = (ControlsManager.get_aim_target_global(self, 300) - gun.global_position).normalized().angle()
	if is_flipped:
		return base_rotation - asin(opposite/hypotnuse) + PI
	return base_rotation + asin(opposite/hypotnuse)


func _on_drop_collected():
	$ColorLauncher.add_pikmin()


func collect_fragment(fragment_value: float):
	$ColorLauncher.collect_fragment(fragment_value)


func register_pikmin_holder(holder):
	pikmin_holder = holder
	$ColorLauncher.pikmin_holder = holder
	$PlayerMover.pikmin_holder = holder


func can_collect_pikmin() -> bool:
	return pikmin_holder.can_collect_pikmin()


func collect_pikmin(pikmin: Pikmin):
	pikmin_holder.collect_pikmin(pikmin)


func make_invulnurable(invulnurable: bool):
	$PlayerHurtbox.dash_invulnurable = invulnurable
