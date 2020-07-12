extends Node2D

func _ready():
	if Controller.flag("floorswitch_1") == 1:
		$FloorSwitch.activate(false)
		
		
func set_flag():
	Controller.set_flag("floorswitch_1", 1)
