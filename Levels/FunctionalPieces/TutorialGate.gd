class_name TutorialGate extends Node2D

@export var world_color_store: WorldColorStore
@export var camera: Camera2D

var _opened = false
var _placed_blocker = false
var _tutorial_room: RoomArea2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GameStateStore.on_first_throw.connect(_start_coloring)


var debug_size = 50.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _opened:
		return
	
	_tutorial_room = GameStateStore.get_current_room()
	if !_placed_blocker && _tutorial_room != null:
		_placed_blocker = true
		_tutorial_room.lock_room(true)
	
	var child_count = 0
	for child in get_children():
		if child != null:
			child_count+=1
	
	if child_count == 1:
		_opened = true
		_tutorial_room.unlock_room()
		HudUiStore.show_dialog.emit("The path is now open, find the exit stairs and good luck!")


func _start_coloring():
	
	HudUiStore.show_dialog.emit("I made your first toss extra powerful as a freebie. Try shooting the remaining skulls.")
	$AnimationPlayer.play("color_room")


func _color_room_step():
	world_color_store.post_draw_room(
		_tutorial_room._room_state,
		debug_size
	)
	debug_size += 50
