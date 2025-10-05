extends Control

@onready var start_button: Button = $VBoxContainer/StartButton
@onready var setting_button: Button = $VBoxContainer/SettingButton
@onready var exit_button: Button = $VBoxContainer/ExitButton
@onready var timer: Timer = $Timer  

@export var next_scene: PackedScene

func _ready() -> void:
	for button: Button in $VBoxContainer.get_children():
		button.mouse_entered.connect(button.grab_focus)
	SoundManager.play_bgm("OpeningMusic")
	SoundManager.setup_ui_sounds(self)
	
	# 连接计时器信号
	timer.timeout.connect(_on_timer_timeout)
	# 确保计时器只触发一次
	timer.one_shot = true

func _on_start_button_pressed() -> void:
	SoundManager.stop_bgm("OpeningMusic")
	LoadScene.change_scene(next_scene)
	#get_tree().change_scene_to_packed(MainScene)

func _on_setting_button_pressed() -> void:
	pass # Replace with function body.

func _on_exit_button_pressed() -> void:
	# 禁用退出按钮，防止多次点击
	exit_button.disabled = true
	# 启动计时器
	timer.start()
	# 可以在这里添加一些反馈，比如在控制台输出
	print("游戏将在", timer.wait_time, "秒后退出...")

func _on_timer_timeout() -> void:
	get_tree().quit()
