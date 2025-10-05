extends Node2D

# 定义旋转速度（每秒弧度）
var rotation_speed: float = 1.0  # 默认1弧度/秒（约57度/秒）

func _ready() -> void:
	pass  # 初始化代码可以放在这里

func _process(delta: float) -> void:
	# 每帧增加旋转角度
	rotation += rotation_speed * delta
