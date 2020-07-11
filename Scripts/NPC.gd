extends StaticBody2D

var in_area := false

onready var interact := $Interact as Sprite


func _process(delta):
	if Input.is_action_just_pressed("sys_interact") and in_area:
		print("TEST")


func _on_AreaInteract_body_entered(body):
	if body.is_in_group("Player"):
		interact.show()


func _on_AreaInteract_body_exited(body):
	if body.is_in_group("Player"):
		interact.hide()
