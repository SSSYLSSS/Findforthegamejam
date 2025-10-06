extends Node2D

@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	SoundManager.play_bgm("Intro2Flat")
	SoundManager.stop_bgm("Intro1")
	player.visible=true
	
func _process(delta: float) -> void:
	pass
