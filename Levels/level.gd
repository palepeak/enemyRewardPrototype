class_name Level extends Node2D

# Global

# Local
@onready var world_color_store: WorldColorStore = $WorldColorStore
@onready var level_map = $LevelMapContainer/SubViewport/LevelMap
@onready var boss_map: BossRoom = $LevelMapContainer/BossRoom
@onready var darkness_particle: DarknessParticle = $LevelMapContainer/DarknessParticles
var player: CharacterBody2D
var room_creator: RoomCreator
var layout_creator: LayoutCreator
var layout_root: LayoutNode
signal init_setup
signal setup_complete


func set_floor(floor_arg: int):
	init_setup.emit()
	var tileset = get_floor_tileset(floor_arg)
	$LevelMapContainer/SubViewport/LevelMap.tile_set = tileset
	$LevelMapContainer/BossRoom.tile_set = tileset
	room_creator = $RoomCreator as RoomCreator
	layout_creator = $LayoutCreator as LayoutCreator
	layout_creator.get_layout(floor_arg)


func _ready():
	#for i in 10:
	#	for y in 10:
	#		var new_pikmin = $Pikmin.duplicate()
	#		var adjust_pos = Vector2(i*10 + 10, y*10 + 10)
	#		new_pikmin.global_position = $Pikmin.global_position + adjust_pos
	#		add_child(new_pikmin)
	# remove the player instance until level setup is complete
	player = $Player as CharacterBody2D
	remove_child(player)
	world_color_store.world_color_progress_update.connect(on_world_color_progress_update)


func _process(_delta):
	if player != null:
		if ControlsManager.using_mouse:
			($Camera2D as Camera2D).position_smoothing_speed = 20
			$Player/ControllerCrosshair.visible = false
		if !ControlsManager.using_mouse:
			($Camera2D as Camera2D).position_smoothing_speed = 5
			$Player/ControllerCrosshair.visible = true
			$Player/ControllerCrosshair.position = (ControlsManager.get_aim_target_local(player, 300))
	$LevelMapContainer/Sprite2D.material.set_shader_parameter(
		"color_map", 
		world_color_store.get_color_texture(),
	)
	darkness_particle.process_material.set_shader_parameter(
		"color_map", 
		world_color_store.get_color_texture(),
	)
	
	var aim_position = ControlsManager.get_aim_target_viewport(self)
	$CanvasLayer/AmmoCount.global_position = aim_position + Vector2(465, 274)
	var camera_adjustment = aim_position/3
	if has_node("Player"):
		$Camera2D.global_position = $Player.global_position + camera_adjustment
		darkness_particle.set_camera_position($Camera2D.global_position)
		darkness_particle.global_position = $Camera2D.global_position


var _temp_shotgun_scene = preload("res://Weapons/shotgun/Shotgun.tscn")

func _on_layout_creator_setup_complete(_node: LayoutNode):
	# debug rooms
	var tut_room = RoomState.new(0, 40, 20, 20, 3, true)
	var room1 = RoomState.new(0, 3, 20, 20, 3)
	var room2 = RoomState.new(40, 3, 30, 20, 3)
	var room2_1 = RoomState.new(65, 53, 30, 30, 3)
	var treasure_room = RoomState.new(40, 50, 10, 10, 3, true)
	var room3 = RoomState.new(90, 3, 15, 30, 3)
	var boss_room = RoomState.new(130, 0, 10, 10, 3, true)
	
	var tut_area = room_creator.create_room(tut_room, level_map, self)
	var room1_area = room_creator.create_room(room1, level_map, self)
	var room2_area = room_creator.create_room(room2, level_map, self)
	var room2_1_area = room_creator.create_room(room2_1, level_map, self)
	var treasure_area = room_creator.create_treasure_room(
		treasure_room, 40, _temp_shotgun_scene,
		level_map, self)
	var room3_area = room_creator.create_room(room3, level_map, self)
	var boss_area = room_creator.create_room(boss_room, level_map, self)
	
	var tut1_exit = tut_room.get_exits(RoomState.RoomDirection.TOP)[0]
	var room1_exit0 = room1.get_exits(RoomState.RoomDirection.BOTTOM)[0]
	room_creator.create_hall(HallState.new(
		tut_area, tut1_exit, 
		room1_area, room1_exit0,
		 3
	), level_map)
	var room1_exit = room1.get_exits(RoomState.RoomDirection.RIGHT)[0]
	var room2_exit = room2.get_exits(RoomState.RoomDirection.LEFT)[0]
	room_creator.create_hall(HallState.new(
		room1_area, room1_exit, 
		room2_area, room2_exit,
		3
	), level_map)
	var room2_exit3 = room2.get_exits(RoomState.RoomDirection.RIGHT)[0]
	var room3_exit1 = room3.get_exits(RoomState.RoomDirection.LEFT)[0]
	room_creator.create_hall(HallState.new(
		room2_area, room2_exit3, 
		room3_area, room3_exit1, 
		3
	), level_map)
	var room2_exit4 = room2.get_exits(RoomState.RoomDirection.BOTTOM)[1]
	var room_2_1_exit1 = room2_1.get_exits(RoomState.RoomDirection.TOP)[0]
	room_creator.create_hall(HallState.new(
		room2_1_area, room_2_1_exit1, 
		room2_area, room2_exit4, 
		3
	), level_map)
	var room2_1_exit2 = room2_1.get_exits(RoomState.RoomDirection.LEFT)[0]
	var treasure_exit = treasure_room.get_exits(RoomState.RoomDirection.RIGHT)[0]
	room_creator.create_hall(HallState.new(
		treasure_area, treasure_exit,
		room2_1_area, room2_1_exit2,
		3
	), level_map)
	
	var room3_exit = room3.get_exits(RoomState.RoomDirection.RIGHT)[0]
	var boss_exit = boss_room.get_exits(RoomState.RoomDirection.LEFT)[0]
	room_creator.create_hall(HallState.new(
		room3_area, room3_exit, 
		boss_area, boss_exit, 
		3
	), level_map)
	var boss_room_label = Label.new()
	boss_room_label.text = "^ Boss battle above"
	boss_room_label.position = 32 * Vector2(boss_room.width/2.0, boss_room.height/2.0)
	boss_area.add_child(boss_room_label)
	
	room_creator.place_boss_room(
		boss_room.get_exits(RoomState.RoomDirection.TOP)[0], 
		level_map, 
		boss_map,
	)
	boss_map.boss_room_entered.connect(entered_boss_room)
	boss_map.boss_room_exited.connect(exited_boss_room)
	
	$LevelMapContainer/SubViewport.size = (level_map.get_used_rect().size * 32)
	$LevelMapContainer/SubViewport2.size = (level_map.get_used_rect().size * 32)
	world_color_store.set_world_state(level_map, boss_map)
	darkness_particle.start_darkness(level_map)
	
	# Level map is only used for visuals, so we need to duplicate it 
	# for the other functionalities like collision and navigation
	var collision_map = level_map.duplicate()
	collision_map.z_index = -1000
	$LevelMapContainer.add_child(collision_map)
	
	#var z_index_1_map = level_map.duplicate() as TileMap
	#z_index_1_map.remove_layer(3)
	#z_index_1_map.remove_layer(2)
	#z_index_1_map.remove_layer(0)
	#z_index_1_map.set_layer_navigation_enabled(0, false)
	#$LevelMapContainer/SubViewport2.add_child(z_index_1_map)
	
	setup_complete.emit()
	PlayerStore.add_player_ref_as_primary(player)
	var initial_spotlight = tut_room.get_center()*32
	player.global_position = initial_spotlight + Vector2(0, 170)
	world_color_store.post_draw_color_point(initial_spotlight)
	$TutorialGate.global_position = initial_spotlight
	add_child(player)
	
	HudUiStore.show_dialog.emit("Welcome hero. Try left click to shoot. Enemies are weakened by the light.")
	
	# level map set, disable updates to save performance 
	($LevelMapContainer/SubViewport as SubViewport).render_target_update_mode = SubViewport.UPDATE_ONCE
	#($LevelMapContainer/SubViewport2 as SubViewport).render_target_update_mode = SubViewport.UPDATE_ONCE



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
	$Camera2D/CameraEnemySpawner.enabled = false
	darkness_particle.fade_out()


func exited_boss_room(_area: Area2D):
	var progress = world_color_store.emitted_progress
	if progress < 95:
		$Camera2D/CameraEnemySpawner.enabled = true
		darkness_particle.fade_in()


func global_coords_on_colored_tile(coords: Vector2) -> bool:
	return world_color_store.global_coords_on_colored_tile(coords)


func get_world_color_store() -> WorldColorStore:
	return world_color_store


func get_camera() -> Camera2D:
	return $Camera2D


func _on_timer_timeout():
	if player != null:
		if !GameStateStore.in_room():
			world_color_store.post_draw_color_point(player.global_position)
			
