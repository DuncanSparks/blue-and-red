extends Area2D

export(String, FILE, "*.tscn") var target_scene: String
export(int, "Up,Down,Left,Right") var target_direction: int


func _on_LoadingZone_body_entered(body):
	var player := get_tree().get_root().get_node("Scene/Player") as KinematicBody2D
	if not player.transforming and not player.stopped and not player.transforming:
		match target_direction:
			0:
				Controller.goto_scene(target_scene, Vector2(player.get_position().x, 160))
			1:
				Controller.goto_scene(target_scene, Vector2(player.get_position().x, 20))
			2:
				Controller.goto_scene(target_scene, Vector2(280, player.get_position().y))
			3:
				Controller.goto_scene(target_scene, Vector2(40, player.get_position().y))
