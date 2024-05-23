class_name UserInterface extends Control

@export var health_sprite: PackedScene

func _ready():
	HudUiStore.world_progress_update.connect(update_progress)
	HudUiStore.player_health_changed.connect(update_health)
	HudUiStore.on_ember_count_changed.connect(update_embers)
	DebugStore.debug_mode_changed.connect(toggle_debug_visiblity)
	HudUiStore.on_ember_progress_changed.connect(_update_ember_progress_ui)


func show_hud():
	update_max_health(3)
	update_health(3)
	update_embers(0)
	$HeatBar.update_heat(0, false)
	_update_ember_progress_ui(0.0)
	visible = true


func update_max_health(new_max_health):
	while new_max_health > $HealthBar.get_child_count():
		var health_lantern = health_sprite.instantiate()
		$HealthBar.add_child(health_lantern)
	while new_max_health < $HealthBar.get_child_count():
		$HealthBar.remove_child($HealthBar.get_children().back())


func update_progress(progress, map: Texture2D):
	$ProgressBar.set_value(progress)
	$Minimap/SubViewport/Sprite2D.texture = map
	$ProgressBar/ColorRect/Sprite2D.material.set_shader_parameter(
		"enabled",
		progress >= GameStateStore.get_clear_percent(),
	)
		
	

func update_health(new_health: int):
	for i in $HealthBar.get_child_count():
		var current_container: HealthLantern = $HealthBar.get_child(i)
		if i < new_health:
			if !current_container.active:
				current_container.start()
		else:
			if current_container.active:
				current_container.stop()


func update_embers(ember_count: int):
	$EmberCount.text = str(ember_count) + "/100 Embers"


func _update_ember_progress_ui(progress: float):
	$EmberProgress/EmberProgressTexture.material.set_shader_parameter("progress", progress)
	$EmberProgress/EmberProgressTexture/EmberProgressLabel.text = str(int(progress*100)) + "%"


func toggle_debug_visiblity(debug_visible: bool):
	($DebugMenu as VBoxContainer).visible = debug_visible
