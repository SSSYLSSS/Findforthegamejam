extends Area2D

@export var spawn_point:SpawnPoint

var player:CharacterBody2D
signal death

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		player=body
		SoundManager.play_sfx("Death")
		timer.start()
		death.emit()

func _on_timer_timeout() -> void:
	player.position=spawn_point.spawn_point
