extends Node2D

func _ready():
	if Controller.flag("demon_door_8") == 1:
		$TileMap2.queue_free()
		
		
func set_flag():
	Controller.set_flag("demon_door_8", 1)
