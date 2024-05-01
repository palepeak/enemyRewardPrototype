class_name HealthLantern extends Container

@onready var sprite = $LanternSprite
var active = true


func stop():
	active = false
	sprite.play("stop")


func start():
	active = true
	sprite.play("start") 


func _on_lantern_sprite_animation_finished():
	if sprite.animation == "start":
		sprite.play("default")
