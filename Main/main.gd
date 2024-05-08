extends Node2D

@onready var loading_screen_loader: LoadingScreenLoader = $CanvasLayer/LoadingScreenLoader
const LEVEL_PATH = "res://Levels/level.tscn"
var level_ready = false
const MUSIC_PLAYER_PATH = "res://Main/FadeMusicPlayer.tscn"

var fade_music_player: FadeMusicPlayer


func _ready():
	var on_music_loaded = func (res):
		fade_music_player = res.instantiate() as FadeMusicPlayer
		add_child(fade_music_player)
	loading_screen_loader.load(MUSIC_PLAYER_PATH, on_music_loaded)
	
	GameStateStore.game_started.connect(start_game)
	GameStateStore.show_title_screen.connect(show_title_screen)
	GameStateStore.show_game_over_screen.connect(show_game_over_screen)
	GameStateStore.toggle_pause_screen.connect(toggle_pause_screen)
	GameStateStore.show_win_screen.connect(show_win_screen)


func start_game():
	PlayerStore.clear_players()
	GameStateStore.remove_level()
	
	$CanvasLayer/TitleScreen.visible = false
	$CanvasLayer/PauseScreen.visible = false
	$CanvasLayer/GameOverScreen.visible = false
	$CanvasLayer/WinScreen.visible = false
	
	level_ready = false
	var on_loaded = func (level_res):
		var current_level = level_res.instantiate() as Level
		current_level.setup_complete.connect(func(): level_ready = true)
		current_level.set_floor(1)
		GameStateStore.set_level(current_level)
		fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackLevel1)
		add_child(current_level)
		$CanvasLayer/Interface.show_hud()
	
	var stop_load_override = func() -> bool: return level_ready
	
		
	loading_screen_loader.load(LEVEL_PATH, on_loaded, stop_load_override)
		


func show_title_screen():
	GameStateStore.remove_level()
	PlayerStore.clear_players()
	fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackTitle)
	
	$CanvasLayer/TitleScreen.show_screen()
	$CanvasLayer/Interface.visible = false
	$CanvasLayer/GameOverScreen.visible = false
	$CanvasLayer/PauseScreen.visible = false
	$CanvasLayer/WinScreen.visible = false


func show_game_over_screen():
	fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackDeath)
	$CanvasLayer/GameOverScreen.show_screen()
	$CanvasLayer/Interface.visible = false


func show_win_screen():
	PlayerStore.clear_players()
	fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackVictory)
	$CanvasLayer/WinScreen.show_screen()
	$CanvasLayer/Interface.visible = false

func toggle_pause_screen():
	get_tree().paused = !get_tree().paused
	$CanvasLayer/PauseScreen.handle_paused()
