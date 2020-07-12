extends Node2D

func _ready():
	if Controller.flag("floorswitch_2") == 1:
		#$TileMap2.queue_free()
		$FloorSwitch.activate(false)
		
		
func set_flag():
	Controller.set_flag("floorswitch_2", 1)
