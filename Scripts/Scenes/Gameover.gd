extends Node2D


func _ready():
	var player := get_node("Player") as KinematicBody2D
	player.stunned = true
	player.get_node("Healthbar").hide()
	player.stop(true)
	player.get_node("Sprite").play("ouch_demon" if player.demon_form else "ouch_human")
	player.get_node("SoundHurt").play()


func _on_Timer_timeout():
	$SoundDie.play()
	Controller.fadeout()
