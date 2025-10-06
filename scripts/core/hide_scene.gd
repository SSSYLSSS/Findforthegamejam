extends Area2D

var hide_node:TileMapLayer

func _ready() -> void:
	hide_node = get_tree().current_scene.get_node("Tilemaps").get_node("HideTileMap")
	hide_node.modulate=Color.html("#ffffff")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		hide_node.z_index=-2
		hide_node.modulate=Color.html("#4e4e4e")
