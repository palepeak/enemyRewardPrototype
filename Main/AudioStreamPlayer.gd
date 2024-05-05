class_name FadeMusicPlayer extends AudioStreamPlayer

enum PlayableTracks {
	title,
	death,
	paused,
	
}
var _next_track_stream: AudioStreamWAV


func fade_into_track(track_name):
	ResourceLoader.load_threaded_request(track_name)
	

func _play_fade_track():
	stream = 


func _get_title_track()
