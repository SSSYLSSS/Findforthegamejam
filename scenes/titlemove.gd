extends Sprite2D

# 浮动参数
var float_speed: float = 1.5
var float_height: float = 2.0  # 小幅度浮动（适配320x180分辨率）
var rotation_speed: float = 0.5
var rotation_factor: int = 1

# 初始位置记录
var origin_y: float

func _ready():
	# 记录初始Y轴位置
	origin_y = position.y
	# 设置纹理居中
	centered = true

func _process(delta):
	# 上下浮动效果（使用正弦波）
	position.y = origin_y + sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_height
	
	# 缓慢旋转效果
	rotation_degrees += rotation_speed * rotation_factor * delta
	
	# 保持旋转角度在0-360范围内
	if abs(rotation_degrees) >= 10:
		rotation_factor = -rotation_factor
