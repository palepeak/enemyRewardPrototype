extends CharacterBody2D


func activate():
	$PlayerTracker.enabled = true
	$EnemyShotManager.activate()
