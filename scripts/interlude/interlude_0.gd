extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@export var next_scene:PackedScene

func _ready() -> void:
	await  get_tree().create_timer(2.0).timeout
	anim.play("default")
	await anim.animation_finished
	LoadScene.change_scene(next_scene)
