class_name Blocker extends StaticBody2D

@export var enabled = false

func _ready():
	set_enabled(enabled)


func set_enabled(enabled_arg: bool):
	enabled = enabled_arg
	$CollisionShape2D.set_disabled.call_deferred(!enabled)
	$Sprite2D.visible = enabled
