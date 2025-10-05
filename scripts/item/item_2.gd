extends Area2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var collision: CollisionShape2D = $CollisionShape2D

var is_positive: bool = true
var float_time: float = 0.5  # 用于浮动的计时器
var float_height: float = 0.004  # 浮动高度（像素）
var float_speed: float = 0.3  # 浮动速度（每秒周期数）

func _ready() -> void:
	# 记录初始位置作为浮动基准
	position.y = position.y  # 确保初始位置正确

func _process(delta: float) -> void:
	# 更新浮动计时器
	float_time += delta
	
	# 使用正弦函数创建上下浮动效果
	var float_offset = sin(float_time * float_speed * PI * 2) * float_height
	
	# 应用浮动效果到节点的Y位置
	position.y = position.y + float_offset

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		if is_positive:
			pass
