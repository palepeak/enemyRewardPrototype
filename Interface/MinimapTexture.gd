extends Sprite2D

var player: Player
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		player = PlayerStore.get_primary_player()
	else:
		global_position = (player.global_position + Vector2(-960/2, -528) + Vector2(0, 32))/-8
