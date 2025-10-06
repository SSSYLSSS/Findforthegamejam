extends Area2D

@export var scene:NextScene
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		var player:CharacterBody2D=body
		player.velocity=Vector2.ZERO
		timer.start()
		player.visible=false
		player.position = scene.next_pos
		await timer.timeout
		LoadScene.change_scene(scene.next_scene)
