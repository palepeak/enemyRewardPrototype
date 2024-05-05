extends Node2D

const LEVEL_PATH = "res://Levels/level.tscn"
var level_loading = false
var level_loaded = false
var current_level: Level


func _ready():
	GameStateStore.start_game.connect(start_game)
	GameStateStore.show_title_screen.connect(show_title_screen)
	GameStateStore.show_game_over_screen.connect(show_game_over_screen)
	GameStateStore.toggle_pause_screen.connect(toggle_pause_screen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	# Loading level using a separate thread, with responsive loading screen 
	if level_loading && not level_loaded:
		var progress_array = []
		var load_progress = ResourceLoader.load_threaded_get_status(LEVEL_PATH, progress_array)
		if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
			current_level = ResourceLoader.load_threaded_get(LEVEL_PATH).instantiate() as Level
			current_level.setup_complete.connect(stop_loading_screen)
			current_level.set_floor(1)
			GameStateStore.set_level(current_level)
			add_child(current_level)
			$CanvasLayer/Interface.show_hud()
			level_loading = false
			level_loaded = true


func start_game():
	PlayerStore.clear_players()
	GameStateStore.remove_level()
	
	$CanvasLayer/TitleScreen.visible = false
	$CanvasLayer/PauseScreen.visible = false
	level_loading = true
	level_loaded = false
	start_loading_screen()
	ResourceLoader.load_threaded_request(LEVEL_PATH)


func show_title_screen():
	GameStateStore.remove_level()
	PlayerStore.clear_players()
	
	$CanvasLayer/TitleScreen.visible = true
	$CanvasLayer/Interface.visible = false
	$CanvasLayer/GameOverScreen.visible = false
	$CanvasLayer/PauseScreen.visible = false


func show_game_over_screen():
	$CanvasLayer/GameOverScreen.show_screen()
	$CanvasLayer/Interface.visible = false


func toggle_pause_screen():
	get_tree().paused = !get_tree().paused
	$CanvasLayer/PauseScreen.visible = get_tree().paused


func stop_loading_screen():
	$CanvasLayer/AnimationPlayer.play("fade_in")


func start_loading_screen():
	$CanvasLayer/AnimationPlayer.play("fade_out")
