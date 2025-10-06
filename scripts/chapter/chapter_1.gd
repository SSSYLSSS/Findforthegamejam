extends Node2D

var force_core_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SoundManager.play_bgm("Intro2Flat")
	SoundManager.stop_bgm("Intro1")
	force_core_node=get_tree().current_scene.get_node("ForceCores")
	var all_children = force_core_node.get_children()
	for child in all_children:
		child.force_in_out = -1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
