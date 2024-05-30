extends CharacterBody2D


func activate():
	$EnemyMover.enabled = true
	$Hurtbox/CollisionShape2D.disabled = false
	$EnemyHitbox/CollisionShape2D.disabled = false
	$HitFlashSprite.material.set_shader_parameter("frame", 0)
