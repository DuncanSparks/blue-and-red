extends Area2D

export(int, "Blue,Red") var color := 0
	
	
func spawn():
	$SoundSpawn.play()
	$PartsSpawn.set_emitting(true)
	$PartsSpawn2.set_emitting(true)
	$Sprite.self_modulate.a = 1.0
	$CollisionShape2D.set_disabled(false)
	
	
func destroy():
	$SoundSpawn.play()
	$PartsSpawn2.set_emitting(true)
	$CollisionShape2D.call_deferred("set_disabled", true)
	var col: Color = $Sprite.get_self_modulate()
	col.a = 0.0
	$Tween.interpolate_property($Sprite, "self_modulate", $Sprite.get_self_modulate(), col, 0.5)
	$Tween.start()
	get_node("..").increment_orbs()


func _on_OrbBlue_body_entered(body: Node) -> void:
	if color == 0:
		destroy()


func _on_BossOrb_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerPounce"):
		destroy()
