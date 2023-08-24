class_name Level extends Node2D

var player: CharacterBody2D
var room_creator: RoomCreator
var layout_creator: LayoutCreator
var layout_root: LayoutNode
signal init_setup
signal setup_complete

func set_floor(floor_arg: int):
	init_setup.emit()
	$LevelMap.tile_set = get_floor_tileset(floor_arg)
	room_creator = $RoomCreator as RoomCreator
	layout_creator = $LayoutCreator as LayoutCreator
	layout_creator.get_layout(floor_arg)


func _ready():
	# remove the player instance until level setup is complete
	player = $Player as CharacterBody2D
	remove_child(player)


func _process(_delta):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport = get_viewport_rect().size
	var bound_mouse_position = Vector2(
		max(0, min(mouse_position.x, viewport.x)),
		max(0, min(mouse_position.y, viewport.y))
	)
	var camera_adjustment = (bound_mouse_position - viewport/2)/3
	if $Player != null:
		$Camera2D.global_position = $Player.global_position + camera_adjustment

func _on_layout_creator_setup_complete(node: LayoutNode):
	# debug rooms
	var room1 = RoomState.new(10, 10, 20, 20, 3)
	var room2 = RoomState.new(60, 10, 20, 20, 3)
	room_creator.create_room(room1, $LevelMap)
	room_creator.create_room(room2, $LevelMap)
	
	var room1_exit = room1.get_exits(RoomState.RoomDirection.RIGHT)[0]
	var room2_exit = room2.get_exits(RoomState.RoomDirection.LEFT)[0]
	room_creator.create_hall(HallState.new(room1_exit, room2_exit, 3), $LevelMap)
	var room1_exit2 = room1.get_exits(RoomState.RoomDirection.RIGHT)[1]
	var room2_exit2 = room2.get_exits(RoomState.RoomDirection.LEFT)[1]
	room_creator.create_hall(HallState.new(room1_exit2, room2_exit2, 3), $LevelMap)
	
	setup_complete.emit()
	add_child(player)
	
func get_floor_tileset(floor_arg) -> TileSet:
	match floor_arg:
		1: 
			return preload("res://Levels/Rooms/Floor1.tres")
		2: 
			return preload("res://Levels/Rooms/Floor2.tres")
		_:
			return preload("res://Levels/Rooms/Floor1.tres")
