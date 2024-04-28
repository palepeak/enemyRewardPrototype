extends Node2D

const LEVEL_PATH = "res://Levels/level.tscn"
var level_loaded = false
var current_level: Level

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request(LEVEL_PATH)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$CanvasLayer/FPSCounter.text = str(Engine.get_frames_per_second())
	
	if not level_loaded:
		var progress_array = []
		var load_progress = ResourceLoader.load_threaded_get_status(LEVEL_PATH, progress_array)
		$loadingProgress.text = str(progress_array[0])
		if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
			current_level = ResourceLoader.load_threaded_get(LEVEL_PATH).instantiate() as Level
			current_level.setup_complete.connect(stop_loading_screen)
			current_level.set_floor(1)
			add_child(current_level)
			level_loaded = true

func stop_loading_screen():
	$CanvasLayer/AnimationPlayer.play("fade_in")
func start_loading_screen():
	$CanvasLayer/AnimationPlayer.play("fade_out")
