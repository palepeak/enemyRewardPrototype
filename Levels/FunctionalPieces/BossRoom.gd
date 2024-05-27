class_name BossRoom extends TileMap

signal boss_room_entered(area: Area2D)
signal boss_room_exited(area: Area2D)

@export var target_progress: int = 95
@export var world_color_store: WorldColorStore


func _ready():
	GameStateStore.set_clear_percent(target_progress)
	$ProgressLockedDoorLeft.target_progress = target_progress
	$ProgressLockedDoorRight.target_progress = target_progress
	world_color_store.world_color_progress_update.connect(_world_color_progress_update)


func _world_color_progress_update(progress: int):
	if $ProgressLockedDoorLeft.locked && progress >= target_progress:
		$ClearAudio.play()
	$ProgressLockedDoorRight.set_progress(progress)
	$ProgressLockedDoorLeft.set_progress(progress)

func _on_win_area_2d_area_entered(area):
	DebugStore.debug_print("Boss room win entered")
	GameStateStore.show_win_screen.emit()


func _on_boss_room_area_2d_area_entered(area):
	DebugStore.debug_print("Boss room entered")
	boss_room_entered.emit(area)


func _on_boss_room_area_2d_area_exited(area):
	DebugStore.debug_print("Boss room exited")
	boss_room_exited.emit(area)
