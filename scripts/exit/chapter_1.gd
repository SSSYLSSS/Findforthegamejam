extends Area2D

@export var next_scene:PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		var player:CharacterBody2D=body
		player.velocity=Vector2.ZERO
		LoadScene.change_scene(next_scene)
	
