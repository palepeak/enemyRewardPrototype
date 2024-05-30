extends CharacterBody2D


func activate():
	$PlayerTracker.enabled = true
	$Hitbox/CollisionShape2D.disabled = false
	$EnemyColorHurtbox.enabled = true
	$EnemyMover.enabled = true
	$HitFlashSprite.material.set_shader_parameter("frame", 0)
