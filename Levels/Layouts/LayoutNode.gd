class_name LayoutNode extends Object

var children: Array[LayoutNode]
var depth: int
var room_type: RoomType
enum RoomType {NORMAL, BOSS, CHEST, SHOP, SPAWN}

func _init(depth_arg: int, room_type_arg: RoomType = RoomType.NORMAL):
	depth = depth_arg
	room_type = room_type_arg

func add_child(child: LayoutNode):
	children.append(child)
	
func get_random_normal_child() -> LayoutNode:
	var valid_children = []
	for child in children:
		if child.room_type == RoomType.NORMAL:
			valid_children.append(child)
	if valid_children.size() == 0:
		print("No valid children")
		return null
	return valid_children.pick_random()
	
	
func debug_print():
	for child in children:
		child.debug_print()
		
	print(str(depth) + str(RoomType.keys()[room_type]))
