extends Sprite2D

# 浮动参数
var float_height: float = 5 # 小幅度浮动（适配320x180分辨率）
var noise_speed: float = 0.5  # 噪声变化速度
var smoothness: float = 0.5   # 平滑度参数（0-1）

# 噪声生成器
var noise = FastNoiseLite.new()
var noise_offset_y: float = 0.0
var noise_offset_x: float = 0.0
var last_position: Vector2

# 初始位置记录
var origin_y: float
var origin_x: float

func _ready():
	# 记录初始位置
	origin_y = position.y
	origin_x = position.x
	# 设置纹理居中
	centered = true
	
	# 配置噪声生成器
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.1
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	
	# 初始化随机偏移
	noise_offset_y = randf() * 1000.0
	noise_offset_x = randf() * 1000.0
	
	# 记录初始位置
	last_position = Vector2(origin_x, origin_y)

func _process(delta):
	# 更新噪声偏移
	noise_offset_y += noise_speed * delta
	noise_offset_x += noise_speed * delta
	
	# 获取噪声值（范围0-1）
	var noise_y = noise.get_noise_1d(noise_offset_y)
	var noise_x = noise.get_noise_1d(noise_offset_x)
	
	# 将噪声值映射到浮动范围（-1到1）
	var target_y = noise_y * 2.0 - 1.0
	var target_x = noise_x * 2.0 - 1.0
	
	# 计算目标位置
	var target_position = Vector2(
		origin_x + target_x * float_height,
		origin_y + target_y * float_height
	)
	
	# 使用平滑插值移动到目标位置
	position = last_position.lerp(target_position, smoothness)
	
	# 更新最后位置
	last_position = position
