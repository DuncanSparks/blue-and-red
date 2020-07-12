extends Node2D

func _ready():
	if Controller.flag("demon_door_7") == 1:
		$TileMap2.queue_free()
		
		
func set_flag():
	Controller.set_flag("demon_door_7", 1)


func checkpoint():
	pass
	#Controller.checkpoint()
