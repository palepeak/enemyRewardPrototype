class_name Player extends CharacterBody2D

# Exports
@export var gun_scene: PackedScene
@export var dead: bool = false
@export var speed = 400

# Global

# Local
@onready var sprite: HitFlashSprite = $HitFlashSprite
@onready var footstep_audio_player: AudioStreamPlayer = $FootstepAudioPlayer
var gun: Node2D
var is_left_hand = false
var gun_one_handed = true
var gun_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	motion_mode = MOTION_MODE_FLOATING
	sprite.play("idle_down")
	sprite.z_index = z_index
	
	if gun_scene != null:
		add_gun(gun_scene.instantiate())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if dead:
		return
	
	var direction = get_aim_position_rotation()
	$PositionLabel.text = str(global_position)
	if not is_left_hand and (direction > 2 * PI/3 or direction < -2 * PI/3):
		# switch to left hand
		is_left_hand = true
		gun.scale = Vector2(-1,1)
		$HitFlashSprite/GunLine/GunPosition.progress_ratio = gun_position
		gun.position = $HitFlashSprite/GunLine/GunPosition.position
		$other_hand.position = $HitFlashSprite/RightHand.position
	elif is_left_hand and (direction > -PI/3 and direction < 1 * PI/3):
		# switch to right hand
		is_left_hand = false
		gun.scale = Vector2(1,1)
		$HitFlashSprite/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
		gun.position = $HitFlashSprite/GunLine/GunPosition.position
		$other_hand.position = $HitFlashSprite/LeftHand.position
	
	if gun != null:
		gun.rotation = get_gun_rotation(is_left_hand)
		gun.z_index = z_index+1
	
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity != Vector2.ZERO && !footstep_audio_player.playing:
		footstep_audio_player.play()
	elif velocity == Vector2.ZERO && footstep_audio_player.playing:
		footstep_audio_player.stop()
	
	var moving = false
	if velocity.length() > 0:
		moving = true
		velocity = velocity.normalized() * speed
	
	# Setting moving animation
	if direction > PI/4 and direction <= 3 * PI/4:
		$other_hand.visible = true
		if moving:
			sprite.play("walk_down")
		else:
			sprite.play("idle_down")
	elif direction > -PI/4 and direction <= PI/4:
		$other_hand.visible = false
		if moving:
			sprite.play("walk_right")
		else:
			sprite.play("idle_right")
	elif direction > -3 * PI/4 and direction <= -PI/4:
		$other_hand.visible = true
		gun.z_index = z_index-1
		if moving:
			sprite.play("walk_up")
		else:
			sprite.play("idle_up")
	else:
		$other_hand.visible = false
		if moving:
			sprite.play("walk_left")
		else:
			sprite.play("idle_left")
		
	set_velocity(velocity)
	move_and_slide()


func add_gun(new_gun: Node2D):
	if gun != null:
		remove_child(gun)
		gun = null
	
	gun = new_gun
	var gun_positioner = gun.find_children("*", "GunPositioner")
	if gun_positioner.size() > 0:
		gun_position = (gun_positioner[0] as GunPositioner).position
		gun_one_handed = (gun_positioner[0] as GunPositioner).one_handed
	$HitFlashSprite/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
	gun.position = $HitFlashSprite/GunLine/GunPosition.position
	if gun_one_handed == true or gun_one_handed == null:
		$other_hand.visible = true
		if is_left_hand:
			$other_hand.position = $HitFlashSprite/RightHand.position
		else:
			$other_hand.position = $HitFlashSprite/LeftHand.position
	else:
		$other_hand.visible = false
	add_child(gun)
	
func remove_gun():
	if gun != null:
		remove_child(gun)
		gun = null
	
func get_aim_position_rotation() -> float:
	return (ControlsManager.get_aim_target_local(self, 300)).normalized().angle()


func get_gun_rotation(is_flipped) -> float:
	var opposite = gun.opposite
	var hypotnuse = ControlsManager.get_aim_target_global(self, 300).distance_to(gun.global_position)
	var base_rotation = (ControlsManager.get_aim_target_global(self, 300) - gun.global_position).normalized().angle()
	if is_flipped:
		return base_rotation - asin(opposite/hypotnuse) + PI
	return base_rotation + asin(opposite/hypotnuse)
