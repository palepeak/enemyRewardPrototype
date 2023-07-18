class_name Test extends Node2D

@export var testFrames: SpriteFrames

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.sprite_frames = testFrames
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
