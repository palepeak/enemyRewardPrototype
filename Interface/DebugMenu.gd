extends VBoxContainer


var player: Player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player == null:
		player = PlayerStore.get_primary_player()
		
	$FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second())
	if player != null:
		$PlayerPosition.text = "Player position: " + str(player.global_position)