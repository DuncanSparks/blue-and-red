extends Area2D

func _ready():
	var time := rand_range(1.2, 2.0)
	$TimerAttack.set_wait_time(time)
	$TimerDestroy.set_wait_time(time + 2.0)
	$TimerAttack.start()
	$TimerDestroy.start()


func _on_TimerAttack_timeout():
	$SoundAttack.play()
	$Sprite.play("attack")
	$CollisionShape2D.set_disabled(false)


func _on_TimerDestroy_timeout():
	$CollisionShape2D.set_disabled(true)
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0)
	$Tween.start()


func _on_Tween_tween_all_completed():
	queue_free()


func _on_OsmeSpike_body_entered(body):
	if body.is_in_group("Player"):
		if not body.iframes and not body.transforming and not body.pouncing and not body.stopped:
			body.hurt(1)
