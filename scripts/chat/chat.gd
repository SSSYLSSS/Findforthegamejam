extends Control

@onready var text_box: Label = $Text/MarginContainer/TextBox
@onready var emoji: AnimatedSprite2D = $Emoji
@onready var emoji_timer: Timer = $Emoji/EmojiTimer
@onready var text: Panel = $Text
@onready var text_timer: Timer = $Text/MarginContainer/TextTimer

@export var chatting:ChattingGroup

var chatting_index:int
var type_tween:Tween

func _ready() -> void:
	text.visible=false
	text_box.visible=false
	emoji.visible=false

	
func play_text_animation():
	if chatting_index>=len(chatting.chatting_list):
		text.visible=false
		return
	var current_chatting = chatting.chatting_list[chatting_index]
	if type_tween.is_running():
		type_tween.kill()
		text_box.text=current_chatting.Text
		chatting_index+=1
	else:
		type_tween=get_tree().create_tween()
		text_box.text=""
		for ch in current_chatting.Text:
			type_tween.tween_callback(func():text_box.text+=ch).\
			set_delay(0.05)
		type_tween.tween_callback(func():chatting_index+=1)
	
func play_emoji_animation():
	var emoji_tween:Tween=create_tween().set_trans(Tween.TRANS_BOUNCE)
	emoji_tween.tween_property(emoji,"position",Vector2(emoji.position.x,emoji.position.y-2.5),0.5)
	emoji.visible=true
	emoji_timer.start()

func _on_emoji_timer_timeout() -> void:
	emoji.visible=false
	emoji.position.y+=2.5

func _on_text_timer_timeout() -> void:
	play_text_animation()
