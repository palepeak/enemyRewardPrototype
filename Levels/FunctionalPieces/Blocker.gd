class_name Blocker extends StaticBody2D

@export var enabled = false

func _ready():
	set_enabled(enabled)


func set_enabled(enabled: bool):
	$CollisionShape2D.set_disabled.call_deferred(!enabled)
	$Sprite2D.visible = enabled
