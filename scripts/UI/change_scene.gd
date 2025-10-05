extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	self.visible=false

func change_scene(target_scene:PackedScene)->void:
	if target_scene==null:
		return
	self.visible=true
	anim.play("trans_in")
	await anim.animation_finished
	get_tree().change_scene_to_packed(target_scene)
	anim.play("trans_out")
	await anim.animation_finished
	self.visible=false
