extends Node2D

# 引力常数，控制引力强度
@export var gravitational_constant: float = 1270.0 #0.000721
# 有效距离，超出此距离不施加力
@export var effective_distance: float = 35.0
# 最小距离，防止除以零错误
@export var min_distance: float = 10.0

var force_in_out: int = 1

# 存储所有可能受引力影响的目标
var potential_targets: Array = []
# 是否有目标在有效距离内
var in_effective_range: bool = false

func _ready() -> void:
	# 获取所有标记为"player"的节点
	potential_targets = get_tree().get_nodes_in_group("player")
	print("找到 ", potential_targets.size(), " 个可能的目标")

func _physics_process(delta: float) -> void:
	# 重置状态
	in_effective_range = false
	
	# 对每个可能的目标检查距离并施加力
	for target in potential_targets:
		if target and is_instance_valid(target):
			# 计算与目标的距离
			var distance = global_position.distance_to(target.global_position)
			
			# 如果距离在有效范围内，施加力
			if distance <= effective_distance and distance > min_distance:
				apply_gravitational_force(target, distance, delta)
				in_effective_range = true
			
			# 检查是否在有效距离内
			check_effective_distance(distance)

func apply_gravitational_force(target: Node2D, distance: float, delta: float) -> void:
	# 计算从目标指向引力球中心的向量
	var to_center = global_position - target.global_position
	
	# 计算力的大小 - 使用平方反比定律
	var force_magnitude = gravitational_constant / (distance * distance)
	
	# 计算力的方向（单位向量）
	var force_direction = to_center.normalized() * force_in_out
	
	# 应用力到目标速度
	if target is CharacterBody2D:
		target.velocity += force_direction * force_magnitude * delta * gravitational_constant
	elif target.has_method("apply_force"):
		# 如果目标有自定义的受力方法，使用它
		target.apply_force(force_direction * force_magnitude * delta)

func check_effective_distance(distance: float) -> void:
	if distance < effective_distance - 10 and distance > 5:
		if force_in_out == 1:
			SoundManager.play_sfx("InForce")
		elif force_in_out == -1:
			SoundManager.play_sfx("OutForce")
	if distance < effective_distance and distance > 5:
		CameraShakeForAll.shake_camera(10 / distance)
# 动态添加目标的方法
func add_target(new_target: Node2D):
	if not potential_targets.has(new_target):
		potential_targets.append(new_target)

# 动态移除目标的方法
func remove_target(target_to_remove: Node2D):
	if potential_targets.has(target_to_remove):
		potential_targets.erase(target_to_remove)

# 更新有效距离的方法
func set_effective_distance(new_distance: float):
	effective_distance = new_distance

# 更新引力常数的方法
func set_gravitational_constant(new_constant: float):
	gravitational_constant = new_constant

func _on_negative_item_negative_hit() -> void:
	force_in_out = 1
	
func _on_positive_item_positive_hit() -> void:
	force_in_out = -1
