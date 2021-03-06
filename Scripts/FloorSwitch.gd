extends Area2D

signal activated

export(int, "Human,Demon") var type: int

var activated := false

func _ready():
	if not activated:
		match type:
			0:
				$Sprite.set_modulate(Color("#002061"))
			1:
				$Sprite.set_modulate(Color("#770000"))
			
			
func activate(sound: bool = true):
	match type:
		0:
			$Sprite.set_modulate(Color("#008aff"))
		1:
			$Sprite.set_modulate(Color("#ff0000"))
	
	if sound:
		$SoundActivated.play()
	activated = true
	emit_signal("activated")


func _on_FloorSwitch_body_entered(body):
	if body.is_in_group("Player") and not activated:
		match type:
			0:
				if body.demon_form:
					return
			1:
				if not body.demon_form:
					return
				
		activate(true)
