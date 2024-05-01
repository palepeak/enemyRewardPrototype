class_name PlayerHealthManager extends CharacterHealthManager


func process_hit(area: Area2D):
	super.process_hit(area)
	print("player_hit")
	PlayerStore.player_health_changed.emit(current_health)


func process_death():
	host_object.process_death()

