class_name EnemyMover extends Node

@export var active: bool = false
@export var speed: int = 100
@export var pathFinder: BasePathFinder
@export var enemy_object: CharacterBody2D
@export var sprite: AnimatedSprite2D

@onready var global_position: Vector2 = enemy_object.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !active || pathFinder.is_navigation_finished():
		return
	
	var axis = enemy_object.to_local(pathFinder.get_next_path_position()).normalized()
	if axis.x > 0:
		sprite.flip_h = true
	elif axis.x < 0:
		sprite.flip_h = false
	enemy_object.velocity = axis * speed
	
	enemy_object.move_and_slide()

