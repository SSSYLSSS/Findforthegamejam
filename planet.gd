extends Node2D

@onready var collision: CollisionShape2D = $Round/CollisionShape2D

var is_in_area: bool
var is_jumping:bool=false
var target: CharacterBody2D
var orbit_speed: float = 3.0  # 公转速度
var orbit_direction: int = -1  # 1为顺时针，-1为逆时针

func _physics_process(delta: float) -> void:
	if is_in_area and target and not is_jumping:
		# 简单的公转效果
		apply_orbit_velocity(delta)

func apply_orbit_velocity(delta: float) -> void:
	# 计算指向中心的向量
	var to_center = global_position - target.global_position
	var distance = to_center.length()
	
	# 计算切向方向（垂直方向）
	var tangent_dir = Vector2(-to_center.y, to_center.x).normalized() * orbit_direction
	
	# 应用切向速度实现公转
	# 速度大小与距离成正比，使公转更自然
	target.velocity = tangent_dir * orbit_speed * distance * 2.5
	
	# 可选：添加轻微的向心力，保持轨道稳定
	# 这可以防止物体因惯性飞离轨道
	var centripetal_force = to_center.normalized() * (distance * 0.1)
	target.velocity += centripetal_force
	
	#这一步是为了判断是否在圈内跳跃,如果跳跃就取消旋转
	if  to_center.y>0 and Input.is_action_just_pressed("jump"):
		target.velocity.x = 0
		target.velocity.y =-200
		is_jumping=true
		await get_tree().create_timer(0.5).timeout
		is_jumping=false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		is_in_area = true
		target = body


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		is_in_area = false
		target = null
