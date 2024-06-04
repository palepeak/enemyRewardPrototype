class_name PlayerMover extends Node2D

@export var player: Player
@export var sprite: HitFlashSprite
@export var speed = 300.0
@export var dodge_roll_duration = 0.7
@export var dodge_roll_speed: Curve
var pikmin_holder: PikminHolder

var _cur_dodge_roll = 0.0
var _dodge_roll_direction = null

@onready var _footstep_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var _roll_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var _roll_fail_audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _arrow
var _arrow_start_pos

var _footstep_audio = preload("res://Resources/footsteps_loop.tres")
var _roll_audio = preload("res://Resources/roll.wav")
var _roll_fail_audio = preload("res://Resources/roll_fail.wav")
var _residual_scene = preload("res://ColorLauncher/ColorBombResidual.tscn")
var _arrow_scene = preload("res://Player/Arrow.tscn")
var _trail_emitter: GPUParticles2D


func _ready():
	_footstep_audio_player.volume_db = -15
	_footstep_audio_player.stream = _footstep_audio
	add_child(_footstep_audio_player)
	_roll_audio_player.stream = _roll_audio
	add_child(_roll_audio_player)
	_roll_fail_audio_player.stream = _roll_fail_audio
	add_child(_roll_fail_audio_player)
	
	_arrow = _arrow_scene.instantiate()
	_arrow.visible = false
	add_child(_arrow)
	
	_trail_emitter = find_child("TrailEmitter")


func _process(delta):
	var velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if velocity != Vector2.ZERO && !_footstep_audio_player.playing:
		_footstep_audio_player.play()
	elif velocity == Vector2.ZERO && _footstep_audio_player.playing:
		_footstep_audio_player.stop()
	velocity = velocity.normalized() * speed
	
	if (
		Input.is_action_just_pressed("dodge_roll") && 
		_dodge_roll_direction == null &&
		velocity != Vector2.ZERO
	):
		_dodge_roll_direction = velocity.normalized()
		_cur_dodge_roll = 0.0
		player.set_gun_enabled(false)
		_arrow_start_pos = global_position
		_arrow.global_rotation = _dodge_roll_direction.angle()
		
		var level = GameStateStore.get_level()
		var world_color_store = level.get_world_color_store()
		if world_color_store.global_coords_on_colored_tile(global_position):
			_start_invul_effects(_dodge_roll_direction.angle())
		else:
			var ember = pikmin_holder.pop_pikmin()
			if ember == null:
				_roll_fail_audio_player.play()
			else:
				_start_invul_effects(_dodge_roll_direction.angle())
				world_color_store.post_draw_color_point(global_position, 40)
				var residual = _residual_scene.instantiate() as ColorBombResidual
				residual.global_position = global_position
				residual.pikmin = ember
				level.add_child.call_deferred(residual)
	
	if _dodge_roll_direction != null:
		_arrow.global_position = _arrow_start_pos
		_arrow.visible = DebugStore.debug_mode
	
		var cur_speed = speed
		if dodge_roll_speed != null:
			cur_speed = speed * dodge_roll_speed.sample(_cur_dodge_roll/dodge_roll_duration)
		velocity = _dodge_roll_direction.normalized() * cur_speed
		
		_cur_dodge_roll += delta
		if _cur_dodge_roll >= dodge_roll_duration:
			_dodge_roll_direction = null
			player.set_gun_enabled(true)
			sprite.play()
		elif _cur_dodge_roll >= dodge_roll_duration/2.0:
			_trail_emitter.emitting = false
			player.make_invulnurable(false)
	else:
		_arrow.visible = false
	
	player.set_velocity(velocity)
	player.move_and_slide()


func _start_invul_effects(direction: float):
	player.make_invulnurable(true)
	_start_trail_emission(direction)
	_roll_audio_player.play()
	

func _start_trail_emission(direction: float):
	var cur_animation = sprite.animation
	if cur_animation == "idle_down":
		sprite.play("walk_down")
		cur_animation = "walk_down"
	elif cur_animation == "idle_right":
		sprite.play("walk_right")
		cur_animation = "walk_right"
	elif cur_animation == "idle_up":
		sprite.play("walk_up")
		cur_animation = "walk_up"
	elif cur_animation == "idle_left":
		sprite.play("walk_left")
		cur_animation = "walk_left"
				
	sprite.pause()
	sprite.frame = 1
	var cur_texture = sprite.sprite_frames.get_frame_texture(cur_animation, 1)
	_trail_emitter.texture = cur_texture
	_trail_emitter.emitting = true
