extends Node2D

const LEVEL_PATH = "level.tscn"
var level_loaded = false

# Called when the node enters the scene tree for the first time.
func _ready():
	ResourceLoader.load_threaded_request(LEVEL_PATH)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not level_loaded:
		var progress_array = []
		var load_progress = ResourceLoader.load_threaded_get_status(LEVEL_PATH, progress_array)
		$loadingProgress.text = str(progress_array[0])
		if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
			var level = ResourceLoader.load_threaded_get(LEVEL_PATH).instantiate()
			$loadingProgress.visible = false
			add_child(level)
			level_loaded = true
