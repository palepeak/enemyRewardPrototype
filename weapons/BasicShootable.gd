class_name BasicShootable extends Area2D

signal successful_shoot()

# Ammo counting and shooting mechanics
@export var max_ammo: int
@export var clip_size: int
@onready var current_ammo = max_ammo
@onready var current_clip_ammo = clip_size
@export var shoot_speed: float
@onready var shoot_timer = Timer.new()
var can_shoot = true
@export var reload_time: float
@onready var reload_timer = Timer.new()
@export var fire_point: CollisionShape2D
@export var chamber_point: Node2D
var in_wall = false

# Audio
@onready var audio_stream_player_shoot = AudioStreamPlayer.new()
@onready var audio_stream_player_reload = AudioStreamPlayer.new()
@export var on_shoot_sfx: AudioStream
@export var on_reload_sfx: AudioStream

# Fire effect
@export var fire_effect: PackedScene
@export var shell_scene: PackedScene

# Recoil
@export var recoil_force_handler: RecoilForce

# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.one_shot = true
	reload_timer.one_shot = true
	shoot_timer.timeout.connect(on_shoot_ready)
	reload_timer.timeout.connect(on_reload_ready)
	add_child(shoot_timer)
	add_child(reload_timer)
	
	audio_stream_player_shoot.max_polyphony = 4
	audio_stream_player_shoot.stream = on_shoot_sfx
	audio_stream_player_reload.stream = on_reload_sfx
	add_child(audio_stream_player_shoot)
	add_child(audio_stream_player_reload)

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		# No ammo left, nothing to do
		if current_ammo <= 0 and current_clip_ammo <= 0:
			return
		# Clip empty, need to reload
		if current_clip_ammo <= 0:
			start_reload()
		try_shoot()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	in_wall = get_overlapping_bodies().size() > 0
	
	if Input.is_action_pressed("r"):
		if current_ammo > 0 and current_clip_ammo != clip_size:
			start_reload()
	
		
func try_shoot():
	if can_shoot && current_clip_ammo > 0 && not in_wall:
			if fire_effect != null:
				var fire = fire_effect.instantiate() as Node2D
				fire.global_position = fire_point.global_position
				fire.rotation = global_rotation
				get_tree().root.add_child(fire)
			if recoil_force_handler != null:
				recoil_force_handler.start_recoil()
			if shell_scene != null:
				var shell = shell_scene.instantiate() as Node2D
				shell.global_position = chamber_point.global_position
				shell.global_rotation = global_rotation
				get_tree().root.add_child(shell)
				
			can_shoot = false
			shoot_timer.start(shoot_speed)
			current_clip_ammo -= 1
			successful_shoot.emit()
			audio_stream_player_shoot.play()

func on_shoot_ready():
	can_shoot = true
	
func start_reload():
	if !reload_timer.is_stopped():
		return
	if !audio_stream_player_reload.playing:
		audio_stream_player_reload.play()
	reload_timer.start(reload_time)

func on_reload_ready():
	# Find how many ammo is needed
	var ammo_needed = clip_size - current_clip_ammo
	# Set the clip size to max clip or ammo left
	current_clip_ammo = min(current_ammo + current_clip_ammo, clip_size)
	current_ammo = max(0, current_ammo - ammo_needed)
