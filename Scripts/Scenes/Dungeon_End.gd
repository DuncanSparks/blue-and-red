extends Node2D

func _ready():
	Controller.fadeout_music("MusicDemon", 2.0)


func initiate_healthbar():
	var tween := $TweenHealthbar as Tween
	tween.interpolate_property($CanvasLayer/HealthbarBoss, "rect_position", Vector2(96, 200), Vector2(96, 162), 4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
