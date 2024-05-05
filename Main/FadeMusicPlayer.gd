class_name FadeMusicPlayer extends Node

enum PlayableTracks {
	TrackTitle,
	TrackDeath,
	TrackLevel1,
	TrackVictory,
}
var _next_track: PlayableTracks
var death_track = preload("res://Resources/music/death_music.tres")


func fade_into_track(track: PlayableTracks):
	_next_track = track
	ResourceLoader.load_threaded_request(_get_title_track(track))
	($AnimationPlayer as AnimationPlayer).play("fade_out")


func _play_fade_track():
	var track_title = _get_title_track(_next_track)
	var load_progress = ResourceLoader.load_threaded_get_status(track_title, [])
	if load_progress == ResourceLoader.THREAD_LOAD_LOADED:
		var result = ResourceLoader.load_threaded_get(_get_title_track(_next_track))
		var stream_player = _get_stream_player(_next_track)
		if stream_player.stream != result:
			stream_player.stream = result
		stream_player.play(stream_player.get_playback_position())
		stream_player.stream_paused = false
		($AnimationPlayer as AnimationPlayer).play("fade_in")
	else:
		DebugStore.debug_print("music load miss: " + track_title)
		($RetryTimer as Timer).start()


func _get_title_track(track: PlayableTracks) -> String:
	if track == PlayableTracks.TrackTitle:
		return "res://Resources/music/title_music.tres"
	elif track == PlayableTracks.TrackDeath:
		return "res://Resources/music/death_music.tres"
	elif track == PlayableTracks.TrackLevel1:
		return "res://Resources/music/level_1_music.tres"
	elif track == PlayableTracks.TrackVictory:
		return "res://Resources/music/victory_music.tres"
	else:
		return ""


func _get_stream_player(track: PlayableTracks) -> AudioStreamPlayer:
	if track == PlayableTracks.TrackLevel1:
		($AudioStreamPlayer as AudioStreamPlayer).stop()
		return $LevelAudioStreamPlayer
	else:
		($LevelAudioStreamPlayer as AudioStreamPlayer).stream_paused = true
		return $AudioStreamPlayer
