extends CharacterBody2D

var _activated = false


func _ready():
	if randi_range(1, 2) == 1:
		$HitFlashSprite.flip_h = true
	$EnemyHitbox/CollisionShape2D.disabled = true


func _process(delta):
	if !_activated && $HitFlashSprite._current_on_color:
		$AudioStreamPlayer2D2.play()
		_activated = true
		$HitFlashSprite.play("start")
		$HitFlashSprite.set_outline_color(Vector4(1.0, 1.0, 1.0, 1.0))


func _on_hit_flash_sprite_animation_finished():
	$EnemyHitbox/CollisionShape2D.disabled = false
	$EnemyMover.active = true
	$EnemyMover.speed = 100
	$EnemyShotManager.activate()
	$EnemyHealthManager.invulnurable = false
	$HitFlashSprite.set_outline_color(Vector4(.92, .46, .25, 1.0))
	collision_mask += pow(2, 5)
	collision_layer += pow(2, 5)
