extends CanvasLayer

onready var sprite := $Sprite as Sprite

var is_red := false


func set_cursor_position(pos: Vector2):
	sprite.set_global_position(pos)
	
	
func change_mode(red: bool):
	if red:
		var tween := $Tween as Tween
		tween.interpolate_property(sprite, "self_modulate", Color("#009cff"), Color.red, 4.0)
		tween.interpolate_property(sprite, "rotation_degrees", 0, 180, 4.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	else:
		var tween := $Tween as Tween
		tween.interpolate_property(sprite, "self_modulate", Color.red, Color("#009cff"), 4.0)
		tween.interpolate_property(sprite, "rotation_degrees", 180, 0, 4.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()

	is_red = red
