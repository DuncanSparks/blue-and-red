extends Node2D


func _ready():
	Controller.deaths += 1
	Controller.can_pause = false
	Controller.get_node("MusicHuman").stop()
	Controller.get_node("MusicDemon").stop()
	var player := get_node("Player") as KinematicBody2D
	player.stunned = true
	player.get_node("Healthbar").hide()
	player.stop(true)
	Controller.stop_timer(true)
	Controller.uninitialize_timer()
	player.get_node("Sprite").play("ouch_demon" if Controller.player_transformed else "ouch_human")
	player.get_node("SoundHurt").play()


func _on_Timer_timeout():
	$SoundDie.play()
	var tween := $Tween as Tween
	tween.interpolate_property($CanvasLayer/Gameover, "self_modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.5)
	tween.start()
	Controller.fadeout()


func _on_Timer2_timeout():
	#Controller.player_transformed = false
	#Controller.goto_scene("res://Scenes/Title.tscn", Vector2())
	Controller.undo_fadeout()
	Controller.restore_checkpoint()


func _on_Tween_tween_all_completed():
	var tween := $Tween2 as Tween
	tween.interpolate_property($CanvasLayer/Gameover, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.5)
	tween.start()
