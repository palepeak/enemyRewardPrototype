class_name ChestIndicator extends ColorRect


# Called when the node enters the scene tree for the first time.
func connect_creasure(treasure: TreasureChest):
	treasure.opened_failed.connect(_jiggle_key)
	treasure.opened.connect(_opened)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _jiggle_key():
	$AnimationPlayer.play("jiggle")
	$AnimationPlayer.seek(0.0)


func _opened():
	$KeySprite.visible = false
	$CheckSprite.visible = true
