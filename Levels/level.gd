class_name Level extends Node2D

# Global

# Local
@onready var world_color_store: WorldColorStore = $WorldColorStore
@onready var level_map = $LevelMapContainer/SubViewport/LevelMap
@onready var boss_map: BossRoom = $LevelMapContainer/BossRoom
var player: CharacterBody2D
var room_creator: RoomCreator
var layout_creator: LayoutCreator
var layout_root: LayoutNode
signal init_setup
signal setup_complete


func set_floor(floor_arg: int):
	init_setup.emit()
	$LevelMapContainer/SubViewport/LevelMap.tile_set = get_floor_tileset(floor_arg)
	room_creator = $RoomCreator as RoomCreator
	layout_creator = $LayoutCreator as LayoutCreator
	layout_creator.get_layout(floor_arg)


func _ready():
	# remove the player instance until level setup is complete
	player = $Player as CharacterBody2D
	remove_child(player)
	world_color_store.world_color_progress_update.connect(on_world_color_progress_update)


func _process(_delta):
	var player = PlayerStore.get_primary_player()
	if player != null:
		if ControlsManager.using_mouse:
			$Player/Crosshair.visible = false
		if !ControlsManager.using_mouse:
			$Player/Crosshair.visible = true
			$Player/Crosshair.position = (ControlsManager.get_aim_target_local(self, 300))
	$LevelMapContainer/Sprite2D.material.set_shader_parameter(
		"color_map", 
		world_color_store.get_color_texture(),
	)
	$LevelMapContainer/DarknessParticles.process_material.set_shader_parameter(
		"color_map", 
		world_color_store.get_color_texture(),
	)
	
	var aim_position = ControlsManager.get_aim_target_viewport(self)
	var camera_adjustment = aim_position
	if has_node("Player"):
		$Camera2D.global_position = $Player.global_position + camera_adjustment

func _on_layout_creator_setup_complete(node: LayoutNode):
	# debug rooms
	var room1 = RoomState.new(0, 0, 20, 20, 3)
	var room2 = RoomState.new(60, 0, 20, 20, 3)
	room_creator.create_room(room1, level_map, self)
	room_creator.create_room(room2, level_map, self)
	
	var room1_exit = room1.get_exits(RoomState.RoomDirection.RIGHT)[0]
	var room2_exit = room2.get_exits(RoomState.RoomDirection.LEFT)[0]
	room_creator.create_hall(HallState.new(room1_exit, room2_exit, 3), level_map)
	var room1_exit2 = room1.get_exits(RoomState.RoomDirection.RIGHT)[1]
	var room2_exit2 = room2.get_exits(RoomState.RoomDirection.LEFT)[1]
	room_creator.create_hall(HallState.new(room1_exit2, room2_exit2, 3), level_map)
	room_creator.place_boss_room(
		room2.get_exits(RoomState.RoomDirection.TOP)[1], 
		level_map, 
		boss_map,
	)
	boss_map.boss_room_entered.connect(entered_boss_room)
	boss_map.boss_room_exited.connect(exited_boss_room)
	
	$LevelMapContainer/SubViewport.size = (level_map.get_used_rect().size * 32)
	world_color_store.set_world_state(level_map, boss_map)
	$LevelMapContainer/DarknessParticles.start_darkness(level_map)
	
	# Level map is only used for visuals, so we need to duplicate it 
	# for the other functionalities like collision and navigation
	var collision_map = level_map.duplicate()
	collision_map.z_index = -1000
	$LevelMapContainer.add_child(collision_map)
	
	setup_complete.emit()
	PlayerStore.add_player_ref_as_primary(player)
	world_color_store.post_draw_color_line(player.global_position, player.global_position)
	add_child(player)
	
	# level map set, disable updates to save performance 
	($LevelMapContainer/SubViewport as SubViewport).render_target_update_mode = SubViewport.UPDATE_ONCE



func get_floor_tileset(floor_arg) -> TileSet:
	match floor_arg:
		1: 
			return preload("res://Levels/Rooms/Floor1.tres")
		2: 
			return preload("res://Levels/Rooms/Floor2.tres")
		_:
			return preload("res://Levels/Rooms/Floor1.tres")


func on_world_color_progress_update(progress: int):
	if progress >= 95:
		$Camera2D/CameraEnemySpawner.enabled = false


func entered_boss_room(_area: Area2D):
	var progress = world_color_store.emitted_progress
	$Camera2D/CameraEnemySpawner.enabled = false
	$LevelMapContainer/DarknessParticles/AnimationPlayer.play("fade_out")


func exited_boss_room(_area: Area2D):
	var progress = world_color_store.emitted_progress
	if progress < 95:
		$Camera2D/CameraEnemySpawner.enabled = true
	$LevelMapContainer/DarknessParticles/AnimationPlayer.play("fade_in")
