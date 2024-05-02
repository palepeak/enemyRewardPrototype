class_name RoomArea2D extends Area2D



func set_room_state(width: int, height: int):
	width *= 32
	height *= 32
	var collision_polygon = $CollisionShape2D.shape as ConvexPolygonShape2D
	var new_points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(0, height),
			Vector2(width, height),
			Vector2(width, 0)
	])
	collision_polygon.points = new_points


func _on_area_entered(area):
	if DebugStore.debug_mode:
		print("player in area" + str(self))


func _on_area_exited(area):
	if DebugStore.debug_mode:
		print("player left area" + str(self))
