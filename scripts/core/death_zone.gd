extends Area2D

@onready var timer: Timer = $Timer

@export var spawn_point:SpawnPoint
var player : CharacterBody2D

func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		player=body
		timer.start()
	
func _on_timer_timeout() -> void:
	after_death()

func after_death():
	# LoadScene.change_scene(load(get_tree().current_scene.scene_file_path))
	await get_tree().create_timer(1.0).timeout
	player.velocity=Vector2.ZERO
	player.position=spawn_point.spawn_point
