class_name CubeAttack extends EnemyAttack

@export var cube_sprite: HitFlashSprite
@export var enemy_mover: EnemyMover
@export var charge_time = 1.0
@export var endlag_time = 1.0
@export var shot_speed = 250
@export var shot_amount: int = 30
@export var bullet_scene: PackedScene = preload("res://EnemyUtils/EnemyBullet.tscn")

var _charging = false
var _charged = false
@onready var _charge_timer: Timer = Timer.new()
@onready var _endlag_timer: Timer = Timer.new()


func _ready():
	_charge_timer.wait_time = charge_time
	_charge_timer.one_shot = true
	_charge_timer.timeout.connect(func():
		_charging = false
		_charged = true
	)
	add_child(_charge_timer)
	
	_endlag_timer.wait_time = endlag_time
	_endlag_timer.one_shot = true
	_endlag_timer.timeout.connect(func(): 
		cube_sprite.play("default")
		enemy_mover.enabled = true
	)
	add_child(_endlag_timer)


func try_attack() -> bool:
	if _charged:
		_charged = false
		_endlag_timer.start()
		cube_sprite.play("attack")
		
		var level = GameStateStore.get_level()
		for i in range(shot_amount+1):
			var bullet = bullet_scene.instantiate() as Bullet
			var direction = Vector2.RIGHT.rotated((i*2.0*PI)/float(shot_amount))
			bullet.fire(global_position, direction, shot_speed, 3000)
			level.add_child(bullet)
	
		return true
	
	if !_charging && !_charged:
		_charging = true
		cube_sprite.play("attack_charge")
		enemy_mover.enabled = false
		_charge_timer.start()
	return false
