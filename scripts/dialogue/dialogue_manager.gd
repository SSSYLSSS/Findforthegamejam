extends Control

@export var avatar:TextureRect
@export var character_name_text:Label
@export var content_text:Label
@export var main_dialogue:DialogueGroup

var dialogue_index:int=0
var type_tween:Tween

func _ready() -> void:
	show_next_dialogue()

func show_next_dialogue():
	if dialogue_index>=len(main_dialogue.dialogue_list):
		self.visible=false
		return
	var next_dialogue:=main_dialogue.dialogue_list[dialogue_index]
	
	if type_tween and type_tween.is_running():
		type_tween.kill()
		content_text.text=next_dialogue.content_text
		dialogue_index+=1
	else:
		type_tween=get_tree().create_tween()
		content_text.text=""
		for ch in next_dialogue.content_text:
			type_tween.tween_callback(func():content_text.text+=ch).\
			set_delay(0.05)
		type_tween.tween_callback(func():dialogue_index+=1)
		avatar.texture=next_dialogue.avatar
		character_name_text.text=next_dialogue.character_name_text
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton \
	and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		show_next_dialogue()
