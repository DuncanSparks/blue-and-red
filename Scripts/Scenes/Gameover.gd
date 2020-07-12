extends Node2D


func _ready():
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
	Controller.fadeout()


func _on_Timer2_timeout():
	Controller.player_transformed = false
	Controller.goto_scene("res://Scenes/Title.tscn", Vector2())
	Controller.undo_fadeout()
