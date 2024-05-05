class_name UserInterface extends Control

@export var health_sprite: PackedScene

func _ready():
	HudUiStore.on_current_clip_ammo_changed.connect(update_ammo)
	HudUiStore.world_progress_update.connect(update_progress)
	HudUiStore.player_health_changed.connect(update_health)
	DebugStore.debug_mode_changed.connect(toggle_debug_visiblity)

func show_hud():
	update_max_health(3)
	update_health(3)
	update_ammo(6)
	visible = true


func update_max_health(new_max_health):
	while new_max_health > $HealthBar.get_child_count():
		var health_lantern = health_sprite.instantiate()
		$HealthBar.add_child(health_lantern)
	while new_max_health < $HealthBar.get_child_count():
		$HealthBar.remove_child($HealthBar.get_children().back())


func update_progress(progress):
	$ProgressBar.set_value(progress)
	

func update_health(new_health: int):
	for i in $HealthBar.get_child_count():
		var current_container: HealthLantern = $HealthBar.get_child(i)
		if i < new_health:
			if !current_container.active:
				current_container.start()
		else:
			if current_container.active:
				current_container.stop()


func update_ammo(ammo_count):
	$AmmoCount.text = str(ammo_count % 7)
	

func toggle_debug_visiblity(debug_visible: bool):
	($DebugMenu as VBoxContainer).visible = debug_visible