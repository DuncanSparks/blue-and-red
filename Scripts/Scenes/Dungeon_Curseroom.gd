extends Node2D

func _ready():
	if Controller.flag("cursed") == 1:
		$NPC/Stone.hide()
		$NPC/Tutorial.show()
		$NPC.talk_number = 1
