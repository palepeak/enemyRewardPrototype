class_name LayoutCreator extends Node

const LINE_BOSS_TARGET_DEPTH = 7
const LINE_CHEST_1_TARGET_DEPTH = 3
const LINE_CHEST_2_TARGET_DEPTH = 6

var thread: Thread

var _level_layout: LayoutNode = null
signal setup_complete(LayoutNode)

func get_layout(dungeon_floor: int):
	thread = Thread.new()
	thread.start(_thread_get_layout.bind(dungeon_floor))
	
func _process(_delta):
	if _level_layout != null:
		setup_complete.emit(_level_layout)
		_level_layout = null
	
	
func _thread_get_layout(dungeon_floor: int):
	var root = _get_line_layout(dungeon_floor)
	_level_layout = root


func _get_line_layout(dungeon_floor: int) -> LayoutNode:
	var root = LayoutNode.new(0, LayoutNode.RoomType.SPAWN)
	
	# make main boss line
	var cur_node = root
	for i in LINE_BOSS_TARGET_DEPTH:
		for n in get_room_length(dungeon_floor):
			var new_node = LayoutNode.new(i+1)
			cur_node.add_child(new_node)
			cur_node = new_node
	var boss_node = get_boss_node()
	cur_node.add_child(boss_node)
	
	# make chest paths and rooms
	make_path(
		LINE_CHEST_2_TARGET_DEPTH, 
		root, 
		dungeon_floor, 
		get_chest_node(LINE_CHEST_2_TARGET_DEPTH),
	)
	make_path(
		LINE_CHEST_1_TARGET_DEPTH, 
		root, 
		dungeon_floor, 
		get_chest_node(LINE_CHEST_1_TARGET_DEPTH),
	)
	
	# make shop path
	var shop_depth = get_line_shop_depth()
	make_path(shop_depth, root, dungeon_floor, get_shop_node(shop_depth))
	
	root.debug_print()
	return root
	
func make_path(target_depth: int, root: LayoutNode, dungeon_floor: int, leaf: LayoutNode):
	# make path to target. cur_node is always a valid pathable node
	var cur_node = root
	while cur_node.depth == 0:
		cur_node = cur_node.get_random_normal_child()
	var target_split_depth = randi_range(0, target_depth-1)
	
	var seen_depths = [0]
	for i in range(1, target_depth):
		var candidate_node = cur_node
		# get the next child that is a different depth
		while candidate_node != null && seen_depths.has(candidate_node.depth):
			candidate_node = candidate_node.get_random_normal_child()
		
		# valid nodes to path off of, lets check it and switch to it if needed
		if candidate_node != null:
			cur_node = candidate_node
			seen_depths.append(cur_node.depth)
		
		# no valid children to traverse to or randomly decided 
		#	to branch into new path
		if candidate_node == null || cur_node.depth >= target_split_depth:
			for n in range(cur_node.depth, target_depth):
				for m in get_room_length(dungeon_floor):
					var new_node = LayoutNode.new(n+1)
					cur_node.add_child(new_node)
					cur_node = new_node
			break
	# make the chest1 room
	cur_node.add_child(leaf)
	

func get_boss_node() -> LayoutNode:
	var boss_node = LayoutNode.new(LINE_BOSS_TARGET_DEPTH, LayoutNode.RoomType.BOSS)
	return boss_node
func get_chest_node(depth: int) -> LayoutNode:
	var chest_node = LayoutNode.new(depth, LayoutNode.RoomType.CHEST)
	return chest_node
func get_shop_node(depth: int) -> LayoutNode:
	var shop_node = LayoutNode.new(depth, LayoutNode.RoomType.SHOP)
	return shop_node

# since this function makes use of random, this value needs to fetched on every use.
func get_room_length(dungeon_floor: int) -> int:
	match dungeon_floor:
		1:
			return 1
		2:
			return randi_range(1,2)
		3:
			return 2
		4:
			return randi_range(2,3)
		_:
			return 3
			
func get_line_shop_depth() -> int:
	return 4 + randi_range(-2,2)

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread.wait_to_finish()
