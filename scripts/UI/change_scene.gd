extends CanvasLayer

@onready var anim: AnimationPlayer = $AnimationPlayer
var player_node:CharacterBody2D

func _ready() -> void:
	self.visible=false
	player_node=get_tree().current_scene.get_node_or_null("Player")

func change_scene(target_scene:PackedScene,pos:Vector2=Vector2.ZERO)->void:
	if target_scene==null:
		return
	SoundManager.play_sfx("Transmusic")
	self.visible=true
	anim.play("trans_in")
	await anim.animation_finished
	if player_node!=null:
		player_node.position=pos
	get_tree().change_scene_to_packed(target_scene)
	anim.play("trans_out")
	await anim.animation_finished
	self.visible=false
