class_name CameraEnemySpawner extends Path2D

@export var enabled: bool = true
@export var enemy_scene: PackedScene
@export var spawn_frequency: float = 10.0
@export var spawn_amount_min: int = 1
@export var spawn_amount_max: int = 1
@onready var spawn_timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_timer.wait_time = spawn_frequency
	if enabled: 
		spawn_timer.start()


func enable():
	enabled = true
	spawn_timer.start()


func disable():
	enabled = false
	spawn_timer.stop()


func _on_timer_timeout():
	spawn_enemies()


func spawn_enemies():
	# get number of enemies
	var number_to_spawn = randi_range(spawn_amount_min, spawn_amount_max)
	for i in number_to_spawn:
		var enemy = enemy_scene.instantiate()
		
		$PathFollow2D.progress_ratio = randf()

		# Set the mob's position to a random location.
		enemy.global_position = $PathFollow2D.global_position
		
		GameStateStore.get_level().add_child(enemy)
	
