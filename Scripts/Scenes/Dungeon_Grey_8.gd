extends Node2D

var opened := false


func _ready():
	if Controller.flag("set_stone_blue"):
		$NPC.talk_number = 1
		$NPC/Stone.show()
		
	if Controller.flag("set_stone_purple"):
		$NPC2.talk_number = 1
		$NPC2/Stone.show()
		
	if Controller.flag("set_stone_red"):
		$NPC3.talk_number = 1
		$NPC3/Stone.show()
	

func _process(delta):
	if not opened:
		if Controller.flag("set_stone_blue") == 1 and Controller.flag("set_stone_purple") == 1 and Controller.flag("set_stone_red") == 1:
			$TileMap2.queue_free()
			opened = true
