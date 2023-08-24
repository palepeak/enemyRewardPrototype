class_name Player extends CharacterBody2D

# Exports
@export var gun_scene: PackedScene

# Stores
@onready var controlsManager = get_node("/root/ControlsManager")

# Global

# Local


var speed = 500
var gun: Node2D
var other_hand: Node2D
var is_left_hand = false
var gun_one_handed = true
var gun_position = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	motion_mode = MOTION_MODE_FLOATING
	$AnimatedSprite2D.play("idle_down")
	$AnimatedSprite2D.z_index = z_index
	
	gun = gun_scene.instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = get_mouse_position_rotation()
	
	if not is_left_hand and (direction > 2 * PI/3 or direction < -2 * PI/3):
		# switch to left hand
		is_left_hand = true
		gun.scale = Vector2(-1,1)
		$AnimatedSprite2D/GunLine/GunPosition.progress_ratio = gun_position
		gun.position = $AnimatedSprite2D/GunLine/GunPosition.position
		other_hand.position = $AnimatedSprite2D/RightHand.position
	elif is_left_hand and (direction > -PI/3 and direction < 1 * PI/3):
		# switch to right hand
		is_left_hand = false
		gun.scale = Vector2(1,1)
		$AnimatedSprite2D/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
		gun.position = $AnimatedSprite2D/GunLine/GunPosition.position
		other_hand.position = $AnimatedSprite2D/LeftHand.position
	
	gun.rotation = get_gun_rotation(is_left_hand)
	gun.z_index = z_index+1
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	var moving = false
	if velocity.length() > 0:
		moving = true
		velocity = velocity.normalized() * speed
	
	# Setting moving animation
	if direction > PI/4 and direction <= 3 * PI/4:
		if moving:
			$AnimatedSprite2D.play("walk_down")
		else:
			$AnimatedSprite2D.play("idle_down")
	elif direction > -PI/4 and direction <= PI/4:
		if moving:
			$AnimatedSprite2D.play("walk_right")
		else:
			$AnimatedSprite2D.play("idle_right")
	elif direction > -3 * PI/4 and direction <= -PI/4:
		gun.z_index = z_index-1
		if moving:
			$AnimatedSprite2D.play("walk_up")
		else:
			$AnimatedSprite2D.play("idle_up")
	else:
		if moving:
			$AnimatedSprite2D.play("walk_left")
		else:
			$AnimatedSprite2D.play("idle_left")
		
	set_velocity(velocity)
	move_and_slide()

func add_gun(gun: Node2D):
	if gun != null:
		remove_child(gun)
		gun = null
	if other_hand != null:
		remove_child(other_hand)
		other_hand = null
	
	var gun_positioner = gun.find_children("*", "GunPositioner")
	if gun_positioner.size() > 0:
		gun_position = (gun_positioner[0] as GunPositioner).position
		gun_one_handed = (gun_positioner[0] as GunPositioner).one_handed
	$AnimatedSprite2D/GunLine/GunPosition.progress_ratio = 1.0 - gun_position
	gun.position = $AnimatedSprite2D/GunLine/GunPosition.position
	if gun_one_handed == true or gun_one_handed == null:
		other_hand.visible = true
		other_hand.position = $AnimatedSprite2D/LeftHand.position
	else:
		other_hand.visible = false
	add_child(gun)
	other_hand = preload("res://weapons/Hand.tscn").instantiate() as Node2D
	add_child(other_hand)
	
func get_mouse_position_rotation() -> float:
	print(str(controlsManager.get_aim_position(self)) + "/" + str(get_global_mouse_position()))
	return (controlsManager.get_aim_position(self) - global_position).normalized().angle()


func get_gun_rotation(is_flipped) -> float:
	var opposite = gun.opposite
	var hypotnuse = controlsManager.get_aim_position(self).distance_to(gun.global_position)
	var base_rotation = (controlsManager.get_aim_position(self) - gun.global_position).normalized().angle()
	if is_flipped:
		return base_rotation - asin(opposite/hypotnuse) + PI
	return base_rotation + asin(opposite/hypotnuse)
