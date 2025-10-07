extends Node

signal camera_should_shake(amount: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shake_camera(amount: float) -> void:
	camera_should_shake.emit(amount)
