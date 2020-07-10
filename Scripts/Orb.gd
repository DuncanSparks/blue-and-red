extends KinematicBody2D

var motion := Vector2.RIGHT
var speed := 300

	
func _physics_process(delta):
	move_and_collide(motion * speed * delta)
	
	
func grow():
	$AnimationPlayerSize.play("Scale")
