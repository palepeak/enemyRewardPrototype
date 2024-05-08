class_name LoadingScreenLoader extends Control
# Design decisions:
#	- Resources loaded from here shouldn't be needed immediately, because of the
#	  Loading screen transitions
#	- These functions should only be used from the main scene

@onready var loading_bar: ProgressBar = $LoadingOverlay/ProgressBar
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var loading = false
var check_progress = false

var _resource_name: String
var _on_loaded_callback: Callable
var _loading_stop_override: Callable

var _loaded_result

var _loading_progress: float

func load(
	resource_name: String, 
	on_loaded_callback: Callable,
	loading_stop_override: Callable = func() -> bool: return true,
):
	if !loading:
		animation_player.play("start_load")
		loading = true
		check_progress = false
		ResourceLoader.load_threaded_request(resource_name)
		_resource_name = resource_name
		_on_loaded_callback = on_loaded_callback
		_loading_stop_override = loading_stop_override
		_loaded_result = null


func start_checking_status():
	check_progress = true
	_check_load_status()


func _process(delta):
	_check_load_status()
	
	if _loaded_result != null && _loading_stop_override.call():
		_loaded_result = null
		_loading_stop_override = func() -> bool: return true
		animation_player.play("stop_load")


func _check_load_status():
	if !loading || !check_progress:
		return
		
	var progress_array = []
	var load_progress = ResourceLoader.load_threaded_get_status(_resource_name, progress_array)
	_loading_progress = progress_array[0]
	loading_bar.value = _loading_progress * 100
	if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
		loading = false
		check_progress = false
		_loaded_result = ResourceLoader.load_threaded_get(_resource_name)
		_on_loaded_callback.call(_loaded_result)
