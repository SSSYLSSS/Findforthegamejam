extends Node2D

@export var begging_pos:Vector2
@export var ending_pos:Vector2
@export var bed_pos:Vector2

@onready var player: Sprite2D = $Player
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var anim_timer: Timer = $AnimationTimer
@onready var emoji: AnimatedSprite2D = $Player/Emoji
@onready var emoji_timer: Timer = $EmojiTimer

func _ready() -> void:
	player.position=begging_pos
	emoji.visible=false
	play_player_animation()
	await get_tree().create_timer(5.2).timeout
	play_bed_animation()

func play_player_animation():
	var player_tween:Tween=create_tween()
	player_tween.tween_property(player,"position",ending_pos,3)
	await player_tween.finished
	anim.play("idle")
	emoji.play("emotional")
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
