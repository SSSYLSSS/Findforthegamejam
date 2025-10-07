extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
var force_core_node

signal negative_hit
var float_time: float = 0.0  # 用于浮动的计时器
var float_height: float = 0.004  # 浮动高度（像素）
var float_speed: float = 0.3  # 浮动速度（每秒周期数）

func _ready() -> void:
	anim.play("up")
	# 记录初始位置作为浮动基准
	
	anim.animation_finished.connect(_on_animation_finished)
	
	position.y = position.y  # 确保初始位置正确
	#获取当前场景的所有的ForceCore的子节点
	force_core_node = get_tree().current_scene.get_node_or_null("ForceCores")
	if not force_core_node:
		force_core_node = get_tree().current_scene.get_node_or_null("ForceCores")
	var all_children = force_core_node.get_children()
	#连接每一个force_core
	for child in all_children:
		if child.has_method("_on_negative_item_negative_hit"):
			self.negative_hit.connect(child._on_negative_item_negative_hit)
	
func _process(delta: float) -> void:
	# 更新浮动计时器
	float_time += delta
	
	# 使用正弦函数创建上下浮动效果
	var float_offset = sin(float_time * float_speed * PI * 2) * float_height
	
	# 应用浮动效果到节点的Y位置
	position.y = position.y + float_offset

func _on_body_entered(body: Node2D) -> void:
	#发送信号
	if body.name == "Player":
		anim.stop()
		anim.play("negativebreak")
		SoundManager.play_sfx("ItemBreak")
		negative_hit.emit()
		# 禁用碰撞防止多次触发
		collision.set_deferred("disabled", true)

# 新增函数：处理动画完成事件
func _on_animation_finished():
	# 检查当前播放的动画是否是"positivebreak"
	if anim.animation == "positivebreak":
		# 动画播放完成后删除节点
		queue_free()
