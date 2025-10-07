extends Area2D

@export var spawn_point: SpawnPoint
var player: CharacterBody2D
signal death
@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player = body
		SoundManager.play_sfx("Death")
		player.freeze_movement()
		timer.start()
		death.emit()

func _on_timer_timeout() -> void:
	player.position = spawn_point.spawn_point
	
	# 重置所有物品
	reset_all_items()
	player.unfreeze_movement()

# 添加重置所有物品的函数
func reset_all_items():
	# 查找场景中所有物品节点
	var positive_items = get_tree().get_nodes_in_group("positive_items")
	var negative_items = get_tree().get_nodes_in_group("negative_items")
	
	for item in positive_items:
		if item.has_method("reset_item"):
			item.reset_item()
	
	for item in negative_items:
		if item.has_method("reset_item"):
			item.reset_item()
