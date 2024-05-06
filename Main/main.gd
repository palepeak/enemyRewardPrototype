extends Node2D

const LEVEL_PATH = "res://Levels/level.tscn"
var level_loading = false
var level_loaded = false
const MUSIC_PLAYER_PATH = "res://Main/FadeMusicPlayer.tscn"
var music_loaded = false
var current_level: Level

var fade_music_player: FadeMusicPlayer


func _ready():
    ResourceLoader.load_threaded_request(MUSIC_PLAYER_PATH)
    
    GameStateStore.game_started.connect(start_game)
    GameStateStore.show_title_screen.connect(show_title_screen)
    GameStateStore.show_game_over_screen.connect(show_game_over_screen)
    GameStateStore.toggle_pause_screen.connect(toggle_pause_screen)
    GameStateStore.show_win_screen.connect(show_win_screen)


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
            fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackLevel1)
            add_child(current_level)
            $CanvasLayer/Interface.show_hud()
            level_loading = false
            level_loaded = true
    
    
    if not music_loaded:
        var progress_array = []
        var load_progress = ResourceLoader.load_threaded_get_status(MUSIC_PLAYER_PATH, progress_array)
        if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
            fade_music_player = ResourceLoader.load_threaded_get(MUSIC_PLAYER_PATH).instantiate() as FadeMusicPlayer
            add_child(fade_music_player)
            music_loaded = true
            stop_loading_screen()


func start_game():
    PlayerStore.clear_players()
    GameStateStore.remove_level()
    
    $CanvasLayer/TitleScreen.visible = false
    $CanvasLayer/PauseScreen.visible = false
    $CanvasLayer/GameOverScreen.visible = false
    $CanvasLayer/WinScreen.visible = false
    level_loading = true
    level_loaded = false
    start_loading_screen()
    ResourceLoader.load_threaded_request(LEVEL_PATH)


func show_title_screen():
    GameStateStore.remove_level()
    PlayerStore.clear_players()
    fade_music_player.fade_into_track(FadeMusicPlayer.PlayableTracks.TrackTitle)
    
    $CanvasLayer/TitleScreen.visible = true
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
    $CanvasLayer/PauseScreen.visible = get_tree().paused


func stop_loading_screen():
    $CanvasLayer/AnimationPlayer.play("fade_in")


func start_loading_screen():
    $CanvasLayer/AnimationPlayer.play("fade_out")
