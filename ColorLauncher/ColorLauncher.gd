class_name ColorLauncher extends Node2D

@export var bomb: PackedScene
@export var bomb_residual: PackedScene
@export var worldColorStore: WorldColorStore
@export var reload_time = 0.5
@export var max_range = 300
@export var minimum_range = 0

@onready var reload_timer: Timer = $Timer
@onready var aim_assister: AimAssist = $AimAssist
var can_launch = true
var pikmin_holder: PikminHolder = null


# Called when the node enters the scene tree for the first time.
func _ready():
	reload_timer.wait_time = reload_time


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("launch_color"):
		aim_assister.visible = true
		_launch_pikmin()
	elif Input.is_action_just_pressed("shoot") || Input.get_action_strength("shoot") >= 0.5:
		aim_assister.visible = false


func _on_reload_timer_timeout():
	can_launch = true


func _launch_pikmin():
	var pikmin = pikmin_holder.pop_pikmin()
	#if pikmin != null:
	$AudioStreamPlayer.play()
	
	var bomb_instance = bomb.instantiate() as ColorBomb
	bomb_instance.curve = aim_assister.get_aim_curve().duplicate()
	bomb_instance.global_position = global_position
	bomb_instance.worldColorStore = worldColorStore
	bomb_instance.residual = bomb_residual
	bomb_instance.pikmin = pikmin
	GameStateStore.get_level().add_child(bomb_instance)


func add_pikmin():
	pikmin_holder.add_pikmin()


func _on_aim_assist_grid_aim_changed():
	_launch_pikmin()
