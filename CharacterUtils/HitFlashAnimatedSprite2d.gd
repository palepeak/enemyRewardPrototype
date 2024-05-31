class_name HitFlashSprite extends AnimatedSprite2D

@export var light_effects_enabled = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var strong_audio_player: AudioStreamPlayer2D = $StrongAudioPlayer
@onready var weak_audio_player: AudioStreamPlayer2D = $WeakAudioPlayer
@onready var none_audio_player: AudioStreamPlayer2D = $NoneAudioPlayer
@onready var world_color_store: WorldColorStore = GameStateStore.get_level().get_world_color_store()

var _current_on_color = false
var _processed_coords
var _processed_pixel

func _process(_delta):
	if !light_effects_enabled:
		return
	if world_color_store == null:
		world_color_store = GameStateStore.get_level().get_world_color_store()
	elif _processed_coords != global_position || _processed_pixel != world_color_store.progress_pixel:
		_processed_coords = global_position
		_processed_pixel = world_color_store.progress_pixel
		var on_color = world_color_store.global_coords_on_colored_tile(global_position)
		if on_color != _current_on_color:
			_current_on_color = on_color
			set_light_shimmer(on_color)
			set_low_contrast(!on_color)


func play_hit_flash():
	world_color_store = GameStateStore.get_level().get_world_color_store()
	var on_color = world_color_store.global_coords_on_colored_tile(global_position)
	if on_color || !light_effects_enabled:
		strong_audio_player.play()
	else:
		weak_audio_player.play()
	animation_player.play("hit")


func play_hit_none_flash():
	animation_player.play("hit_none")
	none_audio_player.play()


func set_light_shimmer(light_shimmer: bool):
	material.set_shader_parameter("outlined", light_shimmer)


func set_low_contrast(low_contrast: bool):
	material.set_shader_parameter("low_contrast", low_contrast)


func set_outline_color(color: Vector4):
	material.set_shader_parameter("line_color", color)


func _advance_shader_hit_frame(_frame: int):
	material.set_shader_parameter("frame", _frame)
