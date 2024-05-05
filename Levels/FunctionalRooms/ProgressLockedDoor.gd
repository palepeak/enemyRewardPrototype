class_name ProgressLockedDoor extends AnimatedSprite2D

@export var locked: bool = true
@export var target_progress: int = 95
var _progress: int = 0

@onready var lock: CollisionShape2D = $RigidBody2D/CollisionShape2D

func set_progress(progress: int):
	_progress = progress
	if _progress >= target_progress && locked:
		locked = false
		play("open")
	elif _progress < target_progress && !locked:
		locked = true
		play("close")
	lock.disabled = !locked
		
