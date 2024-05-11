extends Control


func _ready():
	HudUiStore.on_player_heat_updated.connect(update_heat)


# Called when the node enters the scene tree for the first time.
func update_heat(heat_progress: int, overheated: bool):
	# Don't use 100% progress since that would override boarder box
	$HeatBar.value = min(99, heat_progress)
	$HeatBar.visible = !overheated
	$OverheatedBar.value = heat_progress
	$OverheatedBar.visible = overheated
	
	$WarningAreaLabel.material.set_shader_parameter(
		"enabled",
		heat_progress >= 80 || overheated
	)

