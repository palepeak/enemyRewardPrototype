class_name EnemyShotManager extends Node2D

@export var player_tracker: PlayerTracker

@export var active = true
@export var _can_shoot = false
@export var shot_speed = 250
@export var shot_frequency = 3.0
@export var max_distance = 600
@export var shot_frequency_adjust: Curve
@export var bullet_scene: PackedScene = preload("res://EnemyUtils/EnemyBullet.tscn")
@export var shoot_audio: AudioStream = preload("res://Resources/enemy_shoot.wav")

var _timer: Timer
var _audio_player: AudioStreamPlayer2D

func _ready():
	if active:
		activate()


func _handle_shot():
	_can_shoot = true


func _physics_process(_delta):
	if !active:
		return
	if !_can_shoot:
		return
	var level = GameStateStore.get_level()
	var player = player_tracker.get_tracked_player()
	if !player:
		return
	if !player_tracker.can_see_player():
		return
	if global_position.distance_to(player.global_position) > max_distance:
		return
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.fire(global_position, (player.global_position - global_position).normalized(), shot_speed, 3000)
	level.add_child(bullet)
	_audio_player.play()
	_can_shoot = false
	_timer.wait_time = _get_real_shot_frequency()
	_timer.start()


func _get_real_shot_frequency() -> float:
	return shot_frequency * shot_frequency_adjust.sample(randf())


func activate():
	active = true
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_handle_shot)
	_timer.wait_time = shot_frequency
	add_child(_timer)
	_timer.start()
	
	_audio_player = AudioStreamPlayer2D.new()
	_audio_player.stream = shoot_audio
	_audio_player.volume_db = -5
	add_child(_audio_player)
