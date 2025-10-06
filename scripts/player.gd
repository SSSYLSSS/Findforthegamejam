extends CharacterBody2D

const SPEED = 100.0
const JUMP_VELOCITY = -260.0
const DASH_SPEED: float = 350.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var dash_timer: Timer = $DashTimer
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO

# 郊狼跳跃相关变量
var was_on_floor: bool = false
var coyote_time_active: bool = false
var jump_buffer_active: bool = false
var jump_just_pressed: bool = false  # 新增：记录跳跃键是否刚刚按下

# 状态机
enum PlayerState { 
	IDLE,
	RUN,
	JUMP,
	FALL,
	DASH,
	SIT
}
var current_state: PlayerState = PlayerState.IDLE
var previous_state: PlayerState = PlayerState.IDLE

# SIT状态相关变量
var is_sitting: bool = false
var sit_animation_reversing: bool = false
var sit_animation_frame: int = 0
var sit_animation_progress: float = 0.0

func _ready() -> void:
	add_to_group("player")
	change_state(PlayerState.IDLE)
	was_on_floor = is_on_floor()
	
	# 连接计时器信号
	if coyote_timer:
		coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	if jump_buffer_timer:
		jump_buffer_timer.timeout.connect(_on_jump_buffer_timer_timeout)
	# if dash_timer:
		# dash_timer.timeout.connect(_on_dash_timer_timeout)
	# 这里cheese用了godot自带的信号 所以不用使用脚本连接了

func _physics_process(delta: float) -> void:
	# 保存当前帧的地面状态
	var current_on_floor = is_on_floor()
	
	# 更新郊狼时间（使用当前帧的地面状态）
	update_coyote_time()
	
	# 处理状态
	match current_state:
		PlayerState.IDLE:
			handle_idle_state(delta)
		PlayerState.RUN:
			handle_run_state(delta)
		PlayerState.JUMP:
			handle_jump_state(delta)
		PlayerState.FALL:
			handle_fall_state(delta)
		PlayerState.DASH:
			handle_dash_state(delta)
		PlayerState.SIT:
			handle_sit_state(delta)
	
	# 处理跳跃输入（在所有状态处理之后）
	handle_jump_input()
	
	move_and_slide()
	update_animation()
	
	# 更新地面状态
	was_on_floor = current_on_floor

func update_coyote_time() -> void:
	# 检查是否刚刚离开地面
	if was_on_floor and not is_on_floor() and current_state != PlayerState.JUMP:
		# 启动郊狼时间计时器
		coyote_time_active = true
		if coyote_timer:
			coyote_timer.start()
		#print("郊狼时间启动")
	
	# 如果回到地面，取消郊狼时间
	if is_on_floor():
		coyote_time_active = false
		if coyote_timer:
			coyote_timer.stop()  # 直接停止计时器，不需要先start再stop

func _on_coyote_timer_timeout() -> void:
	# 郊狼时间结束
	coyote_time_active = false
	#print("郊狼时间结束")

func _on_jump_buffer_timer_timeout() -> void:
	# 跳跃缓冲时间结束
	jump_buffer_active = false
	#print("跳跃缓冲结束")

func change_state(new_state: PlayerState) -> void:
	previous_state = current_state
	current_state = new_state
	
	# 进入新状态时的处理
	match new_state:
		PlayerState.DASH:
			start_dash()
		PlayerState.SIT:
			start_sit()

func handle_idle_state(_delta: float) -> void:
	apply_custom_gravity(_delta)
	handle_jump_input()
	handle_movement_input()
	
	# 检查是否应该坐下
	if Input.is_action_just_pressed("down") and is_on_floor():
		change_state(PlayerState.SIT)
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			change_state(PlayerState.JUMP)
		else:
			change_state(PlayerState.FALL)
	elif has_horizontal_input():
		change_state(PlayerState.RUN)
	
	handle_dash_input()

func handle_run_state(_delta: float) -> void:
	apply_custom_gravity(_delta)
	handle_jump_input()
	handle_movement_input()
	
	# 检查是否应该坐下
	if Input.is_action_just_pressed("down") and is_on_floor():
		change_state(PlayerState.SIT)
		return
	
	if not is_on_floor():
		if velocity.y < 0:
			change_state(PlayerState.JUMP)
		else:
			change_state(PlayerState.FALL)
	elif not has_horizontal_input():
		change_state(PlayerState.IDLE)
	
	handle_dash_input()

func handle_jump_state(_delta: float) -> void:
	apply_custom_gravity(_delta)
	handle_movement_input()
	
	if velocity.y >= 0:
		change_state(PlayerState.FALL)
	elif is_on_floor():
		if has_horizontal_input():
			change_state(PlayerState.RUN)
		else:
			change_state(PlayerState.IDLE)
	
	handle_dash_input()

func handle_fall_state(_delta: float) -> void:
	apply_custom_gravity(_delta)
	handle_movement_input()
	
	if is_on_floor():
		if has_horizontal_input():
			change_state(PlayerState.RUN)
		else:
			change_state(PlayerState.IDLE)
	elif velocity.y < 0:
		change_state(PlayerState.JUMP)
	
	handle_dash_input()

func handle_dash_state(_delta: float) -> void:
	# 冲刺状态下不应用重力，保持直线运动
	if dash_timer and dash_timer.is_stopped():
		# 如果冲刺方向是向上的，则在冲刺结束时将竖直速度置为0
		if dash_direction.y < 0:  # 向上冲刺
			velocity.y = -100
		
		if is_on_floor():
			if has_horizontal_input():
				change_state(PlayerState.RUN)
			else:
				change_state(PlayerState.IDLE)
		else:
			if velocity.y < 0:
				change_state(PlayerState.JUMP)
			else:
				change_state(PlayerState.FALL)

func handle_sit_state(_delta: float) -> void:
	# 坐下状态下不能移动
	velocity.x = 0
	
	# 处理坐下动画
	handle_sit_animation()
	
	# 检查是否应该站起
	if not Input.is_action_pressed("down") and not sit_animation_reversing:
		# 松开down键，开始反向播放动画
		sit_animation_reversing = true
		anim.play_backwards("sit")
	
	# 检查是否在反向播放过程中再次按下蹲下键
	if Input.is_action_just_pressed("down") and sit_animation_reversing:
		# 保存当前帧和进度
		var current_frame = anim.frame
		var current_progress = anim.frame_progress
		
		# 切换到正向播放
		sit_animation_reversing = false
		anim.play("sit")
		
		# 从当前帧开始正向播放
		anim.set_frame_and_progress(current_frame, current_progress)
	
	# 如果动画反向播放完成，回到IDLE状态
	if sit_animation_reversing and anim.frame == 0:
		# 重置状态变量
		sit_animation_reversing = false
		change_state(PlayerState.IDLE)
	
	# 坐下状态下可以冲刺
	handle_dash_input()

func apply_custom_gravity(delta: float) -> void:
	if not is_on_floor() and current_state != PlayerState.DASH:
		var gravity_value = ProjectSettings.get_setting("physics/2d/default_gravity")
		var gravity_vector = ProjectSettings.get_setting("physics/2d/default_gravity_vector")
		var gravity = gravity_vector * gravity_value
		velocity += gravity * delta

func handle_jump_input() -> void:
	# 检测跳跃输入
	if Input.is_action_just_pressed("jump"):
		# 设置跳跃缓冲
		jump_buffer_active = true
		if jump_buffer_timer:
			jump_buffer_timer.start()
		#print("跳跃输入检测，启动跳跃缓冲")
	
	# 检查是否可以执行跳跃（包括郊狼时间和跳跃缓冲）
	var can_jump = (is_on_floor() or coyote_time_active) and current_state != PlayerState.SIT
	
	if can_jump and jump_buffer_active:
		velocity.y = JUMP_VELOCITY
		change_state(PlayerState.JUMP)
		
		# 跳跃后重置状态
		coyote_time_active = false
		jump_buffer_active = false
		if coyote_timer:
			coyote_timer.stop()
		if jump_buffer_timer:
			jump_buffer_timer.stop()
		#print("跳跃执行")
	
	# 另外，检查跳跃缓冲是否活跃并且当前满足条件（例如刚刚落地）
	if jump_buffer_active and is_on_floor() and current_state != PlayerState.SIT:
		velocity.y = JUMP_VELOCITY
		change_state(PlayerState.JUMP)
		jump_buffer_active = false
		if jump_buffer_timer:
			jump_buffer_timer.stop()
		#print("跳跃缓冲执行")

func handle_movement_input() -> void:
	var input_vector := get_movement_input()
	
	# 坐下状态下不能移动
	if current_state == PlayerState.SIT:
		return
	
	# 更新角色朝向
	if input_vector.x != 0:
		update_character_direction(input_vector.x)

	if input_vector.length() > 0:
		velocity.x = input_vector.x * SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)

# 检查是否有水平输入
func has_horizontal_input() -> bool:
	return Input.is_action_pressed("left") or Input.is_action_pressed("right")

func get_movement_input() -> Vector2:
	var input_vector := Vector2.ZERO
	
	if Input.is_action_pressed("right"):
		input_vector.x += 1
	if Input.is_action_pressed("left"):
		input_vector.x -= 1
	if Input.is_action_pressed("down"):
		input_vector.y += 1
	if Input.is_action_pressed("up"):
		input_vector.y -= 1
	
	return input_vector.normalized() if input_vector.length() > 0 else Vector2.ZERO

func update_character_direction(direction: float) -> void:
	if direction > 0:
		anim.flip_h = false
	elif direction < 0:
		anim.flip_h = true

func handle_dash_input() -> void:
	if Input.is_action_just_pressed("dash") and can_dash:
		change_state(PlayerState.DASH)

func start_dash() -> void:
	SoundManager.play_sfx("Dash")
	# 获取八方向输入
	var input_vector := get_movement_input()
	
	# 如果没有输入方向，使用当前朝向
	if input_vector == Vector2.ZERO:
		input_vector = Vector2(1 if not anim.flip_h else -1, 0)
	
	dash_direction = input_vector.normalized()
	
	# 计算冲刺速度
	var dash_velocity = dash_direction * DASH_SPEED
	
	# 如果是向上冲刺，确保有足够的垂直速度
	if dash_direction.y < 0:
		# 确保垂直速度至少达到最小跳跃速度
		dash_velocity.y = min(dash_velocity.y, JUMP_VELOCITY * 0.8)
	
	velocity = dash_velocity
	if dash_timer:
		dash_timer.start()
	can_dash = false
	
	# 创建残影效果
	create_dash_trails()

func create_dash_trails() -> void:
	# 使用协程创建连续的残影
	for i in range(10):
		# 确保仍在冲刺状态
		if current_state != PlayerState.DASH:
			break
			
		trail_system()
		await get_tree().create_timer(0.05).timeout

func trail_system():
	var trail = preload("res://scenes/trail.tscn").instantiate()
	get_parent().add_child(trail)
	get_parent().move_child(trail, get_index())
	
	# 设置残影的位置和基本属性
	trail.global_position = anim.global_position
	trail.flip_h = anim.flip_h
	
	# 如果是AnimatedSprite2D残影
	if trail is AnimatedSprite2D:
		trail.sprite_frames = anim.sprite_frames
		trail.animation = anim.animation
		trail.frame = anim.frame
		trail.modulate = Color(1, 1, 1, 0.5)
	# 如果是Sprite2D残影
	elif trail is Sprite2D:
		var current_sprite = anim.sprite_frames.get_frame_texture(anim.animation, anim.frame)
		trail.texture = current_sprite
		trail.modulate = Color(1, 1, 1, 0.5)

func start_sit() -> void:
	# 初始化坐下状态
	is_sitting = true
	sit_animation_reversing = false
	sit_animation_frame = 0
	sit_animation_progress = 0.0
	anim.play("sit")

func handle_sit_animation() -> void:
	# 保存当前帧和进度
	sit_animation_frame = anim.frame
	sit_animation_progress = anim.frame_progress
	
	# 如果正在播放坐下动画且没有反向播放
	if not sit_animation_reversing:
		# 检查是否到达最后一帧
		if anim.frame == 5:  # 最后一帧
			# 停在最后一帧
			anim.stop()
			# 使用set_frame_and_progress确保停在最后一帧
			anim.set_frame_and_progress(5, 0.0)
	
	# 如果正在反向播放
	if sit_animation_reversing:
		# 确保动画正确反向播放
		if not anim.is_playing() or anim.animation != "sit":
			anim.play_backwards("sit")
		
		# 保存反向播放时的帧和进度
		sit_animation_frame = anim.frame
		sit_animation_progress = anim.frame_progress

func update_animation() -> void:
	match current_state:
		PlayerState.IDLE:
			anim.play("idle")
		PlayerState.RUN:
			anim.play("run")
		PlayerState.JUMP:
			anim.play("jump")
		PlayerState.FALL:
			anim.play("fall")
		PlayerState.DASH:
			var dash_anim = get_dash_animation(dash_direction)
			anim.play(dash_anim)
		PlayerState.SIT:
			if not anim.is_playing():
				anim.set_frame_and_progress(sit_animation_frame, sit_animation_progress)

func get_dash_animation(direction: Vector2) -> String:
	if direction.y > 0.1:
		return "fall"
	elif direction.y < -0.5:
		if abs(direction.x) > 0.3:
			return "dash_upforward"
		else:
			return "dash_up"
	else:
		return "dash_forward"

func _on_dash_timer_timeout() -> void:
	can_dash = true
