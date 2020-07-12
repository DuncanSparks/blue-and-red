extends Node2D


func _ready():
	if Controller.flag("meet_ivari") == 1:
		$NPCIvari.talk_number = 1
