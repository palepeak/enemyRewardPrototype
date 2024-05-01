class_name PlayerHitbox extends Area2D

signal player_hit(area: Area2D)

@export var invulnerability_time: float = 2.0
var _invulnerable_timer: Timer
var _invulnerable = false


# Called when the node enters the scene tree for the first time.
func _ready():
	_invulnerable_timer = $Timer
	_invulnerable_timer.wait_time = invulnerability_time
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if has_overlapping_areas() && !_invulnerable:
		_invulnerable = true
		_invulnerable_timer.start()
		player_hit.emit(get_overlapping_areas().front())


func _on_timer_timeout():
	_invulnerable = false
