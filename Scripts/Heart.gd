extends Area2D

var picked_up := false

func _ready():
	if (get_node("..").filename + name) in Controller.collected_hearts:
		queue_free()
		

func _on_Heart_body_entered(body):
	if body.is_in_group("Player") and not picked_up and not body.stopped and not body.transforming and body.health < 5:
		body.heal(2)
		picked_up = true
		$Sprite.hide()
		$Particles.set_emitting(true)
		Controller.collected_hearts[get_node("..").filename + name] = true
		$Timer.start()
