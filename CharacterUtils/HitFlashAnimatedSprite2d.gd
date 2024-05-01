class_name HitFlashSprite extends AnimatedSprite2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D


func play_hit_flash():
	animation_player.play("hit")
	audio_player.play()
