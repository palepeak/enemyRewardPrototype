class_name HealthLantern extends Container

@onready var sprite = $LanternSprite


func stop():
	sprite.play("stop")


func start():
	sprite.play("start") 


func _on_lantern_sprite_animation_finished():
	if sprite.animation == "start":
		sprite.play("default")
