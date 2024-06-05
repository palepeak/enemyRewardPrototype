class_name EnemyAttackManager extends Node2D

@export var attack: EnemyAttack

@export var active = true
@export var attack_frequency = 3.0
@export var attack_frequency_adjust: Curve
@export var attack_audio: AudioStream = preload("res://Resources/enemy_shoot.wav")

var _can_shoot = false
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
	var result = _try_attack()
	if result:
		_audio_player.play()
		_can_shoot = false
		_timer.wait_time = _get_real_attack_frequency()
		_timer.start()


func _try_attack() -> bool:
	return attack.try_attack()
	

func _get_real_attack_frequency() -> float:
	return attack_frequency * attack_frequency_adjust.sample(randf())


func activate():
	active = true
	_timer = Timer.new()
	_timer.one_shot = true
	_timer.timeout.connect(_handle_shot)
	_timer.wait_time = _get_real_attack_frequency()
	add_child(_timer)
	_timer.start()
	
	_audio_player = AudioStreamPlayer2D.new()
	_audio_player.stream = attack_audio
	_audio_player.volume_db = -5
	add_child(_audio_player)
