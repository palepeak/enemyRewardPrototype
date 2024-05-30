extends CharacterBody2D


func activate():
	$PlayerTracker.enabled = true
	$Hitbox/CollisionShape2D.disabled = false
	$Hurtbox/CollisionShape2D2.disabled = false
	$HitFlashSprite.material.set_shader_parameter("frame", 0)
