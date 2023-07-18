extends CharacterBody2D

@export var gun_scene: PackedScene

var speed = 500
var gun
var is_left_hand = false

# Called when the node enters the scene tree for the first time.
func _ready():
	motion_mode = MOTION_MODE_FLOATING
	$AnimatedSprite2D.play("idle_down")
	gun = gun_scene.instantiate()
	gun.position = $AnimatedSprite2D/GunRight.position
	add_child(gun)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = get_mouse_position_rotation()
	if not is_left_hand and (direction > 2 * PI/3 or direction < -2 * PI/3):
		# switch to left hand
		is_left_hand = true
		gun.scale = Vector2(-1,1)
		gun.position = $AnimatedSprite2D/GunLeft.position
	elif is_left_hand and (direction > -PI/3 and direction < 1 * PI/3):
		# switch to right hand
		is_left_hand = false
		gun.scale = Vector2(1,1)
		gun.position = $AnimatedSprite2D/GunRight.position
		
	
	gun.rotation = get_gun_rotation(is_left_hand)
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("d"):
		velocity.x += 1
	if Input.is_action_pressed("a"):
		velocity.x -= 1
	if Input.is_action_pressed("s"):
		velocity.y += 1
	if Input.is_action_pressed("w"):
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
		if moving:
			$AnimatedSprite2D.play("walk_up")
		else:
			$AnimatedSprite2D.play("idle_up")
	else:
		if moving:
			$AnimatedSprite2D.play("walk_left")
		else:
			$AnimatedSprite2D.play("idle_left")
	
	if direction > -PI and direction < 0:
		gun.z_index = z_index-1
	else:
		gun.z_index = z_index+1
		
	set_velocity(velocity)
	move_and_slide()

	
func get_mouse_position_rotation() -> float:
	return (get_global_mouse_position() - global_position).normalized().angle()


func get_gun_rotation(is_flipped) -> float:
	var opposite = gun.opposite
	var hypotnuse = get_global_mouse_position().distance_to(gun.global_position)
	var base_rotation = (get_global_mouse_position() - gun.global_position).normalized().angle()
	if is_flipped:
		return base_rotation - asin(opposite/hypotnuse) + PI
	return base_rotation + asin(opposite/hypotnuse)
