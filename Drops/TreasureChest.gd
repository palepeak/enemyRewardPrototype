class_name TreasureChest extends StaticBody2D

signal opened()
signal opened_failed()

@export var reward: PackedScene
@export var required_coverage: int
@export var world_color_store: WorldColorStore

var _drop_scene = preload("res://Drops/WeaponDrop.tscn")
var _opened = false
var _spawned_reward


func _process(delta):
	if _spawned_reward != null:
		_spawned_reward.position = Vector2(
			0, 
			min(50, _spawned_reward.position.y + delta * 100)
		)


func _on_interactable_on_interaction():
	if _opened:
		return
	if world_color_store.progress_percent < required_coverage:
		opened_failed.emit()
		$OpenedFailedSFX.play()
		return
		
	_opened = true
	opened.emit()
	$TreasureChest.play("open")
	$ChestOpenSFX.play()
	print("opened")
	_spawned_reward = _drop_scene.instantiate() as WeaponDrop
	_spawned_reward.weapon = reward
	add_child(_spawned_reward)
