extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$PointLight2D1.global_position = $PointLight2D1.global_position + Vector2(randf_range(-5,5), randf_range(-5,5))
	$PointLight2D2.global_position = $PointLight2D1.global_position +  Vector2(randf_range(-5,5), randf_range(-5,5))
	$PointLight2D3.global_position = $PointLight2D1.global_position +  Vector2(randf_range(-5,5), randf_range(-5,5))
