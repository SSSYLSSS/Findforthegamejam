extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_positive:bool = true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_positive:
			pass
