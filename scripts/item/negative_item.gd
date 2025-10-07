extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
var force_core_node

signal negative_hit
var float_time: float = 0.0
var float_height: float = 0.004
var float_speed: float = 0.3
var initial_position: Vector2  # 添加初始位置记录
var is_collected: bool = false  # 添加收集状态标志

func _ready() -> void:
	# 记录初始位置
	self.add_to_group("negative_items")
	initial_position = position
	reset_item()  # 初始化物品状态
	
	# 连接动画完成信号
	anim.animation_finished.connect(_on_animation_finished)
	
	# 获取ForceCore节点
	force_core_node = get_tree().current_scene.get_node_or_null("ForceCores")
	if force_core_node:
		var all_children = force_core_node.get_children()
		for child in all_children:
			if child.has_method("_on_negative_item_negative_hit"):
				self.negative_hit.connect(child._on_negative_item_negative_hit)

# 添加重置函数
func reset_item():
	is_collected = false
	position = initial_position
	anim.play("up")
	collision.disabled = false
	show()

func _process(delta: float) -> void:
	if is_collected:
		return  # 如果已收集，不执行浮动效果
		
	float_time += delta
	var float_offset = sin(float_time * float_speed * PI * 2) * float_height
	position.y = position.y + float_offset

func _on_body_entered(body: Node2D) -> void:
	if is_collected or body.name != "Player":
		return
		
	print("negative_hit")
	is_collected = true
	anim.stop()
	anim.play("negativebreak")
	SoundManager.play_sfx("ItemBreak")
	CameraShakeForAll.shake_camera(4)
	negative_hit.emit()
	Engine.time_scale = 0.01
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1
	collision.set_deferred("disabled", true)

func _on_animation_finished():
	if anim.animation == "negativebreak":
		hide()  # 隐藏而不是删除
