extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready():
	HudUiStore.on_player_heat_updated.connect(heat_updated)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func heat_updated(heat, overheated):
	value = heat
