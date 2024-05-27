class_name Interactable extends Node2D

signal on_interaction()

var player_tracker: PlayerTracker


func _ready():
	player_tracker = PlayerTracker.new()
	player_tracker.enabled = true
	player_tracker.calculate_vision = false
	player_tracker.max_distance = 50
	add_child(player_tracker)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		var player = player_tracker.get_tracked_player()
		if player != null:
			on_interaction.emit()
