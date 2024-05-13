class_name PlayerHitbox extends Area2D

signal player_hit(area: Area2D)
signal drop_collected()

@onready var player_instance: Player = get_parent()
@export var invulnerability_time: float = 2.0
var _invulnerable_timer: Timer
var _invulnerable = false
var _delta_counter = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	_invulnerable_timer = $Timer
	_invulnerable_timer.wait_time = invulnerability_time
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if has_overlapping_areas() && !_invulnerable:
		_invulnerable = true
		_delta_counter = 0.0
		_invulnerable_timer.start()
		player_hit.emit(get_overlapping_areas().front())
	
	# Handle invulnurability flash
	if _invulnerable:
		_delta_counter += delta
		if int(_delta_counter/0.25) % 2 == 0:
			player_instance.visible = true
		else:
			player_instance.visible = false
	else:
		player_instance.visible = true

func _on_timer_timeout():
	_invulnerable = false
