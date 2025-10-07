extends Control

@onready var quit: Button = $V/Actions/H/Quit
@onready var timer: Timer = $Timer
@onready var resume: Button = $V/Actions/H/Resume

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	SoundManager.setup_ui_sounds(self)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func show_setting() -> void:
	show()
	resume.grab_focus()

func _on_resume_pressed() -> void:
	hide()
	pass # Replace with function body.


func _on_quit_pressed() -> void:
		# 禁用退出按钮，防止多次点击
	quit.disabled = true
	# 启动计时器
	timer.start()
	# 可以在这里添加一些反馈，比如在控制台输出
	print("游戏将在", timer.wait_time, "秒后退出...")
	pass # Replace with function body.
func _on_timer_timeout() -> void:
	get_tree().quit()
