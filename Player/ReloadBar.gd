extends ProgressBar

@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	HudUiStore.reload_started.connect(play_reload)


func play_reload(duration: float):
	animation_player.speed_scale = 1.0/duration
	animation_player.play("reload")
