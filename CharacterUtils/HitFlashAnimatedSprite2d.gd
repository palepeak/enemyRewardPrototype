class_name HitFlashSprite extends AnimatedSprite2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

var _frame = 0


func play_hit_flash():
	animation_player.play("hit")
	audio_player.play()


func set_light_shimmer(light_shimmer: bool):
	material.set_shader_parameter("outlined", light_shimmer)


func _advance_shader_hit_frame():
	_frame = (_frame + 1) % 3
	material.set_shader_parameter("frame", _frame)
