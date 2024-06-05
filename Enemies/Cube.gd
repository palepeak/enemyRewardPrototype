class_name CubeEnemy extends CharacterBody2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$HitFlashSprite.position = Vector2(randi_range(-1, 1), randi_range(-1, 1))


func activate():
	$Hurtbox/CollisionShape2D.disabled = false
	$EnemyHitbox/CollisionShape2D.disabled = false
	$HitFlashSprite.material.set_shader_parameter("frame", 0)
	$EnemyAttackManager.activate()
