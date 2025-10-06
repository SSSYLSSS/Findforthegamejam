extends Node

@onready var emoji: AnimatedSprite2D = $Player/Emoji
@onready var text: Panel = $Player/Text
@onready var text_box: Label = $Player/Text/TextBox
@onready var text_timer: Timer = $Player/TextTimer

func _ready() -> void:
	SoundManager.play_bgm("Intro1")
	emoji.visible=false
	text.visible=false
	text_box.visible=false
	await get_tree().create_timer(2.0).timeout
	feeling_system()

func _process(delta: float) -> void:
	pass

func feeling_system():
	text_box.visible=true
	text_box.text="陌生的天花板"
	text.visible=true
	text_timer.start()
	await text_timer.timeout
	text_box.text="...?..."
	text_timer.start()
	await text_timer.timeout
	text_box.text="...我在哪里"
	text_timer.start()
	await text_timer.timeout
	text_box.text="...头好痛"
	text_timer.start()
	await text_timer.timeout
	text.visible=false
	text_box.visible=false
	emoji.play("sad")
	emoji.visible=true
	await get_tree().create_timer(1.5).timeout
	emoji.play("confusing")
	await get_tree().create_timer(1.0).timeout
	emoji.visible=false
