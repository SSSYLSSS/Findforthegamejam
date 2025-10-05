extends CPUParticles2D

func _ready() -> void:
	# 基本设置
	emitting = true
	amount = 50
	lifetime = 0.45
	one_shot = false
	explosiveness = 0.0
	local_coords = false
	
	# 设置粒子纹理
	texture = create_pixel_texture()
	
	# 配置粒子参数
	setup_particle_parameters()
	
	# 设置粒子位置到父节点中心
	set_particle_position_to_parent_center()

func setup_particle_parameters() -> void:
	# 发射形状 - 使用球体发射替代环形发射
	emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	emission_sphere_radius = 10.0  # 球的半径
	
	# 初始速度 - 设置为0，主要靠加速度运动
	initial_velocity_min = 0.0
	initial_velocity_max = 0.0
	
	# 重力 - 设置为0，避免垂直下落
	gravity = Vector2(0, 0)
	
	# 方向 - 设置为0，让加速度控制运动
	direction = Vector2(0, 0)
	spread = 0.0
	
	# 切向加速度 - 创建旋转效果
	tangential_accel_min = 200.0
	tangential_accel_max = 300.0
	
	# 径向加速度 - 向心效果（负值表示向中心运动）
	radial_accel_min = -20.0
	radial_accel_max = 30.0
	
	# 阻尼 - 控制运动平滑度
	damping_min = 0.5
	damping_max = 0.7
	
	# 使用角度参数控制旋转
	# 这些是CPUParticles2D实际支持的属性
	angle_min = 0.0
	angle_max = 360.0  # 全角度发射
	
	# 粒子大小 - 使用正确的属性名
	scale = Vector2(1,1)
	
	# 缩放曲线
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))
	scale_curve.add_point(Vector2(1.0, 1.0))
	# self.scale_curve = scale_curve
	
	# 颜色设置
	color = Color(0.5, 0.3, 0.8)
	color_ramp = create_color_ramp()

func create_color_ramp() -> Gradient:
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(0.3, 0.5, 0.9))  # 蓝色
	gradient.add_point(0.5, Color(0.6, 0.2, 0.8))  # 紫色
	gradient.add_point(1.0, Color(0.3, 0.5, 0.9, 0))  # 淡出
	return gradient

func create_pixel_texture() -> ImageTexture:
	var image = Image.create(1, 1, false, Image.FORMAT_RGBA8)
	image.fill(Color(1, 1, 1))
	return ImageTexture.create_from_image(image)

func set_particle_position_to_parent_center() -> void:
	if get_parent():
		if get_parent() is Control:
			global_position = get_parent().global_position + get_parent().size / 2
		elif get_parent() is Node2D:
			global_position = get_parent().global_position
	else:
		position = Vector2(160, 90)

# 调整旋风强度 - 使用实际存在的属性
func set_vortex_strength(strength: float) -> void:
	tangential_accel_min = strength * 80.0
	tangential_accel_max = strength * 100.0
	radial_accel_min = strength * -20.0
	radial_accel_max = strength * -30.0

# 通知处理
func _notification(what):
	if what == NOTIFICATION_PARENTED:
		set_particle_position_to_parent_center()
	elif what == Control.NOTIFICATION_RESIZED:
		set_particle_position_to_parent_center()
	elif what == Node2D.NOTIFICATION_TRANSFORM_CHANGED:
		set_particle_position_to_parent_center()
