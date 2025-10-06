extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_bgm("Intro2Flat")
	SoundManager.stop_bgm("Intro1")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
