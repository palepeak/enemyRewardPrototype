extends CharacterBody2D


func activate():
	$PlayerTracker.enabled = true
	$EnemyAttackManager.activate()
	$Hurtbox/CollisionShape2D.disabled = false
	$EnemyHitbox/CollisionShape2D.disabled = false
	$HitFlashSprite.material.set_shader_parameter("frame", 0)
