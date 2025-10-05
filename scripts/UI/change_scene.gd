extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

var last_scene:PackedScene

func _ready() -> void:
	self.visible=false

func change_scene(target_scene:PackedScene)->void:
	self.visible=true
	last_scene=target_scene
	anim.play("trans_in")
	await anim.animation_finished
	get_tree().change_scene_to_packed(last_scene)
	anim.play("trans_out")
	await anim.animation_finished
	self.visible=false
