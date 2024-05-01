class_name UserInterface extends Node2D

@export var health_sprite: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	update_max_health(3)
	GunStore.on_current_clip_ammo_changed.connect(update_ammo)
	WorldColorStore.world_progress_update.connect(update_progress)
	PlayerStore.player_health_changed.connect(update_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CanvasLayer/FPSCounter.text = str(Engine.get_frames_per_second())


func update_max_health(new_max_health):
	while new_max_health > $CanvasLayer/HealthBar.get_child_count():
		var health_lantern = health_sprite.instantiate()
		$CanvasLayer/HealthBar.add_child(health_lantern)
	while new_max_health < $CanvasLayer/HealthBar.get_child_count():
		$CanvasLayer/HealthBar.remove_child($CanvasLayer/HealthBar.get_children().back())


func update_progress(progress):
	$CanvasLayer/ProgressBar.set_value(progress)
	

func update_health(new_health: int):
	for i in $CanvasLayer/HealthBar.get_child_count():
		var current_container: HealthLantern = $CanvasLayer/HealthBar.get_child(i)
		if i < new_health:
			if !current_container.active:
				current_container.start()
		else:
			if current_container.active:
				current_container.stop()


func update_ammo(ammo_count):
	$CanvasLayer/AmmoCount.text = str(ammo_count % 7)
