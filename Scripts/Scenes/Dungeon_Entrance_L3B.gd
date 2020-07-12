extends Node2D

func _ready():
	if Controller.flag("demon_door_5") == 1:
		$TileMap2.queue_free()
		
	if Controller.flag("floorswitch_3") == 1:
		$TileMap3.queue_free()
		
		
func set_flag():
	Controller.set_flag("demon_door_5", 1)
	

func set_flag_2():
	Controller.set_flag("floorswitch_3", 1)
