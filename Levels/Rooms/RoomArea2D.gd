class_name RoomArea2D extends Area2D

var _blocker_scene = preload("res://Levels/FunctionalPieces/Blocker.tscn")
var _ghost_scene = preload("res://Enemies/EnemyGhost.tscn")
var _skull_scene = preload("res://Enemies/Skull.tscn")
var _sleeping_skeleton_scene = preload("res://Enemies/SleepingSkeleton.tscn")
var _skeleton_scene = preload("res://Enemies/Skeleton.tscn")
var _slime_scene = preload("res://Enemies/Slime.tscn")
var _enemy_count = 0
var _enemies = []
var _blocker_map = {}

var _room_state: RoomState
var _neighbors: Array[RoomArea2D] = []
var _spawned_neighbors = false
var _spawned = false
var _cleared = false
var _entered = false


func set_room_state(room_state: RoomState):
	_room_state = room_state
	
	position = Vector2(
		(_room_state.x+1)*32, 
		(_room_state.y+_room_state.wall_height-1) * 32,
	)
	
	var width = _room_state.width * 32
	var height = (_room_state.height + 2) * 32
	var collision_polygon = $CollisionShape2D.shape as ConvexPolygonShape2D
	var new_points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(0, height),
			Vector2(width, height),
			Vector2(width, 0)
	])
	collision_polygon.points = new_points


func mark_exit_used(
	exit: Vector2, 
	direction: RoomState.RoomDirection, 
	neighbor: RoomArea2D,
):
	_neighbors.append(neighbor)
	_room_state.mark_exit_used(exit)
	var blocker = _blocker_scene.instantiate() as Blocker
	add_child(blocker)
	blocker.global_position = exit * 32
	if direction == RoomState.RoomDirection.LEFT || direction == RoomState.RoomDirection.RIGHT:
		blocker.global_rotation = PI/2
	_blocker_map[exit] = blocker


func perform_initial_spawn():
	if _spawned || _room_state.custom_room:
		return
	
	temp_create_enemies()


func temp_create_enemies():
	if _spawned || _room_state.custom_room:
		return
	_spawned = true
	
	var area = _room_state.width * _room_state.height
	var amount = randi_range(area/200, 2*area/200)
	var placed = _scatter(_skull_scene, amount, [], false)
	
	#placing fake skulls
	amount = randi_range(area/400, 2*area/400)
	placed = _scatter(_sleeping_skeleton_scene, amount, placed, false)
	
	#placing skeletons
	amount = randi_range(area/300, 2*area/300)
	placed = _scatter(_skeleton_scene, amount, placed, true)
	
	#placing ghosts
	amount = randi_range(area/200, 2*area/200)
	placed = _scatter(_ghost_scene, amount, placed, true)
	#placing slime
	amount = 2*area/200 - amount
	placed = _scatter(_slime_scene, amount, placed, true)


func _scatter(
	scatter_scene: PackedScene, 
	amount: int, 
	placed_coords: Array[Vector2] = [],
	is_clear_enemy: bool = true,
) -> Array[Vector2]:
	var area = _room_state.width * _room_state.height
	var placed = 0
	while placed < amount:
		var x_candidate = randi_range(1, _room_state.width-1)
		var y_candidate = randi_range(
			_room_state.wall_height-2,
			_room_state.height+_room_state.wall_height-3
		)
		var candidate = Vector2(x_candidate, y_candidate)
		if !placed_coords.has(candidate):
			var node = scatter_scene.instantiate()
			node.position = candidate * 32
			
			if is_clear_enemy:
				var defeat_obs = DefeatObserver.new()
				defeat_obs.on_defeated.connect(_remove_enemy_ref)
				node.add_child.call_deferred(defeat_obs)
				_enemy_count += 1
				
			add_child.call_deferred(node)
			_enemies.append(node)
			placed +=1
			placed_coords.append(candidate)
	return placed_coords


func _remove_enemy_ref():
	_enemy_count -= 1
	if _enemy_count == 0:
		_cleared = true
		$LevelClearStream.play()
		for lock in _blocker_map.values():
			lock.set_enabled(false)


func _on_area_entered(area):
	if !_cleared && !_entered:
		_entered = true
		if !_room_state.custom_room:
			$LevelClearStream.play()
		for lock in _blocker_map.values():
			lock.set_enabled(!_room_state.custom_room)
		for enemy in _enemies:
			if enemy != null && enemy.has_method("activate"):
				enemy.activate()
	
	GameStateStore.set_room(self)
	DebugStore.debug_print("player in area" + str(self))


func _on_area_exited(area):
	if !_spawned_neighbors:
		_spawned_neighbors = true
		for neighbor in _neighbors:
			neighbor.perform_initial_spawn()
	
	GameStateStore.set_room(null)
	DebugStore.debug_print("player left area" + str(self))
