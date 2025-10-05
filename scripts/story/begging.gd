extends Node2D

@export var beginning_pos:Vector2
@export var ending_pos:Vector2
@export var next_scene:PackedScene

@onready var player: Sprite2D = $Player
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var emoji: AnimatedSprite2D = $Player/Emoji
@onready var emoji_timer: Timer = $EmojiTimer
@onready var click: Control = $Click
@onready var text: Panel = $Player/Text
@onready var text_box: Label = $Player/Text/TextBox
@onready var click_timer: Timer = $ClickTimer

var can_be_preesed:=false

func _ready() -> void:
	player.position=beginning_pos
	emoji.visible=false
	click.visible=false
	can_be_preesed=false
	text.visible=false
	await get_tree().create_timer(1.0).timeout
	play_player_animation()
	await get_tree().create_timer(5.2).timeout
	click.visible=true

func play_player_animation():
	text.visible=true
	text_box.text="...难受..."
	var player_tween:Tween=create_tween()
	player_tween.tween_property(player,"position",ending_pos,3)
	await player_tween.finished
	anim.play("idle")
	emoji.play("emotional")
	text.visible=false
	play_emoji_animation()
	
func play_emoji_animation():
	emoji.visible=true
	var emoji_tween:=create_tween().set_ease(Tween.EASE_IN_OUT)
	emoji_tween.tween_property(emoji,"position",Vector2(emoji.position.x,emoji.position.y-2.5),0.5)
	emoji_timer.start()

func play_bed_animation():
	anim.play("goto_bed")
	await anim.animation_finished
	emoji.play("comfortable")
	play_emoji_animation()
	await emoji_timer.timeout

func _on_emoji_timer_timeout() -> void:
	emoji.visible=false
	emoji.position=Vector2(emoji.position.x,emoji.position.y+2.5)

func _on_click_gui_input(event: InputEvent) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event is InputEventMouseButton:
		if not can_be_preesed:
			play_bed_animation()
			can_be_preesed=true
			click_timer.start()
		else:
			if click_timer.time_left>0:
				return
			LoadScene.change_scene(next_scene)
