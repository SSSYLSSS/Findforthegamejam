extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var setting_button: Button = $VBoxContainer/SettingButton
@onready var exit_button: Button = $VBoxContainer/ExitButton

@export var MainScene:PackedScene

func _ready() -> void:
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(MainScene)

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	get_tree().quit()
