extends Node

@onready var sfx: Node = $SFX
@onready var bgm: Node = $BGM

enum Bus { MASTER, SFX, BGM }

@onready var bgm_nubmer: int = 0
# 存储当前正在播放的BGM
var current_bgm_player: AudioStreamPlayer = null
# 存储所有正在进行的Tween动画
var active_tweens: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func play_sfx(name: String) -> void:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.play()
	
func stop_sfx(name: String) -> void:
	var player := sfx.get_node(name) as AudioStreamPlayer
	if not player:
		return
	player.stop()

func setup_ui_sounds(node: Node) -> void:
	var button := node as Button
	if button: 
		# 连接前先检查是否已连接，避免重复连接
		if not button.pressed.is_connected(play_sfx.bind("UIPress")):
			button.pressed.connect(play_sfx.bind("UIPress"))
		if not button.focus_entered.is_connected(play_sfx.bind("UIin")):
			button.focus_entered.connect(play_sfx.bind("UIin"))
		if not button.mouse_entered.is_connected(button.grab_focus):
			button.mouse_entered.connect(button.grab_focus)
	
	var slider := node as Slider
	if slider: 
		# 修复信号连接并添加重复检查
		var sfx_bind = play_sfx.bind("UIPress").unbind(1)
		if not slider.value_changed.is_connected(sfx_bind):
			slider.value_changed.connect(sfx_bind)
		if not slider.focus_entered.is_connected(play_sfx.bind("UIin")):
			slider.focus_entered.connect(play_sfx.bind("UIin"))
		if not slider.mouse_entered.is_connected(slider.grab_focus):
			slider.mouse_entered.connect(slider.grab_focus)
	
	
	for child in node.get_children():
		setup_ui_sounds(child)
		
func play_bgm(name: String, fade_in_time: float = 0.5) -> void:
	var player := bgm.get_node(name) as AudioStreamPlayer
	if not player:
		return
	
	# 停止当前BGM（带淡出效果）
	if current_bgm_player and current_bgm_player != player:
		stop_bgm(current_bgm_player.name, fade_in_time)
	
	# 设置新BGM
	current_bgm_player = player
	bgm_nubmer = player.get_index()
	
	# 淡入效果
	if fade_in_time > 0:
		player.volume_db = -20  # 从静音开始
		player.play()
		
		var tween = create_tween()
		tween.tween_property(player, "volume_db", 0.0, fade_in_time)
		active_tweens.append(tween)
	else:
		player.volume_db = 0.0
		player.play()

func stop_bgm(name: String, fade_out_time: float = 1.0) -> void:
	var player := bgm.get_node(name) as AudioStreamPlayer
	if not player:
		return
	
	# 淡出效果
	if fade_out_time > 0:
		var tween = create_tween()
		tween.tween_property(player, "volume_db", -10.0, fade_out_time)
		tween.tween_callback(player.stop)
		active_tweens.append(tween)
	else:
		player.stop()
	
	# 如果停止的是当前BGM，清除引用
	if player == current_bgm_player:
		current_bgm_player = null
	
func stop_all_bgm(fade_out_time: float = 1.0) -> void:
	for player in bgm.get_children():
		if player is AudioStreamPlayer and player.playing:
			stop_bgm(player.name, fade_out_time)
	
	current_bgm_player = null

# 清理所有活动的Tween动画
func _exit_tree() -> void:
	for tween in active_tweens:
		if tween and tween.is_running():
			tween.kill()
	active_tweens.clear()

func get_volume(bus_index: int) -> float:
	var db := AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(db)

func set_volume(bus_index: int, v: float) -> void:
	var db := linear_to_db(v)
	AudioServer.set_bus_volume_db(bus_index, db)
