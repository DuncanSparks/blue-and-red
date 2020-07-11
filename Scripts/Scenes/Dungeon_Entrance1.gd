extends Node2D


func _ready():
	if Controller.flag("game_start") == 0:
		$AnimationPlayer.play("Start")
		Controller.set_flag("game_start", 1)
