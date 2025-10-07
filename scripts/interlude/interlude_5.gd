extends Control

@onready var anim: AnimationPlayer = $AnimationPlayer
@export var scene:NextScene
@onready var control: Control = $Control
@onready var label: Label = $HBoxContainer/Label
@onready var label_2: Label = $HBoxContainer/Label2
@onready var title: Label = $Title

func _ready() -> void:
	control.visible=false
	label.visible=true
	label_2.visible=true
	title.visible=false
	await  get_tree().create_timer(2.0).timeout
	anim.play("default")
	await anim.animation_finished
	await  get_tree().create_timer(0.75).timeout
	label.visible=false
	label_2.visible=false
	title.visible=true
	anim.play("ending")
	await anim.animation_finished
	control.visible=true

func _on_control_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		get_tree().change_scene_to_packed(load("res://scenes/menu.tscn"))
