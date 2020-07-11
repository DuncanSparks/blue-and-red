extends KinematicBody2D

var motion := Vector2.RIGHT
var speed := 300


func _process(delta):
	var pos := get_global_position()
	if pos.x <= -30 or pos.x >= 350 or pos.y <= -30 or pos.y >= 210:
		queue_free()

	
func _physics_process(delta):
	move_and_collide(motion * speed * delta)
	
