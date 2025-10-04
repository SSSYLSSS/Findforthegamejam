extends Area2D

@onready var collision: CollisionShape2D = $CollisionShape2D

var is_in_area:bool
var target:CharacterBody2D
var to_center:Vector2
var raduis
var raduis_offset= 5

func _ready() -> void:
	var shape:CircleShape2D= collision.shape
	raduis = shape.radius

func _physics_process(delta: float) -> void:
	if is_in_area:
		to_center = target.global_position-self.global_position
		target.look_at(self.global_position)
		if to_center.length()<raduis-raduis_offset:
			target.velocity.y = -50
		target.velocity.x = to_center.rotated(-PI/2).x * 2
		
func _on_body_entered(body: Node2D) -> void:
	if body.name=="Player":
		is_in_area=true
		target=body

func _on_body_exited(body: Node2D) -> void:
	if body.name=="Player":
		is_in_area=false
		body.rotation = 0
