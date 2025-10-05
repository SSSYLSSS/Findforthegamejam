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
	player.position=beginning_pos #主角传送到指定位置
	emoji.visible=false
	click.visible=false
	can_be_preesed=false
	text.visible=false
	#防止还没加载完就移动
	await get_tree().create_timer(1.0).timeout
	play_player_animation()
	SoundManager.play_bgm("Beginning")
	print("ready")
	

func play_player_animation():
	#显示对话
	text.visible=true
	text_box.text="...难受..."
	var player_tween:Tween=create_tween()
	player_tween.tween_property(player,"position",ending_pos,3)
	await player_tween.finished
	#切换动作
	anim.play("idle")
	text.visible=false
	#显示表情
	await get_tree().create_timer(0.5).timeout
	emoji.play("emotional")
	play_emoji_animation()
	
func play_emoji_animation():
	emoji.visible=true
	#处理动画
	var emoji_tween:=create_tween().set_ease(Tween.EASE_IN_OUT)
	emoji_tween.tween_property(emoji,"position",Vector2(emoji.position.x,emoji.position.y-2.5),0.5)
	emoji_timer.start()
	#让玩家自己推进剧情
	await emoji_timer.timeout
	click.visible=true

func play_bed_animation():
	#很诡异的动画
	anim.play("goto_bed")
	await anim.animation_finished
	emoji.play("comfortable")
	play_emoji_animation()
	await emoji_timer.timeout

func _on_emoji_timer_timeout() -> void:
	#把表情移回原处
	emoji.visible=false
	emoji.position=Vector2(emoji.position.x,emoji.position.y+2.5)

func _on_click_gui_input(event: InputEvent) -> void:
	#左键推进剧情
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and event is InputEventMouseButton:
		if not can_be_preesed:
			play_bed_animation()
			can_be_preesed=true
			click_timer.start()
		else:
			if click_timer.time_left>0:
				return
			LoadScene.change_scene(next_scene)
