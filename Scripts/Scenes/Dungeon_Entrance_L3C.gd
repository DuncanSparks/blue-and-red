extends Node2D

func _ready():
	if Controller.flag("stone_blue") == 1:
		$NPC.talk_number = 1
		$NPC/Stone.hide()
