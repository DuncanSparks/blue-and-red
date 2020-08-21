extends Control

export(AudioStream) var hover_sound: AudioStream
export(AudioStream) var click_sound: AudioStream

var in_credits := false
var exited_credits := false

onready var but1 := $HBoxContainer/Button as TextureButton
onready var but2 := $HBoxContainer/Button2 as TextureButton
onready var but3 := $HBoxContainer/Button3 as TextureButton


func _ready():
	if Cursor.is_red:
		Cursor.change_mode(false)
		
	Controller.can_pause = false
	Controller.run_speedrun_stats = false
	Controller.speedrun_timer.hide()
	Controller.healthbar.hide()
	Controller.stone1.hide()
	Controller.stone2.hide()
	Controller.stone3.hide()


func _process(delta):
	if in_credits and not exited_credits and Input.is_action_just_pressed("attack"):
		var tween := $TweenCredits as Tween
		tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0.8), Color(0, 0, 0, 0), 1.0)
		tween.interpolate_property($CanvasLayer/Credits, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0)
		tween.start()
		exited_credits = true
	
	
func hover():
	if not but1.disabled:
		Controller.play_sound_oneshot(hover_sound, rand_range(0.95, 1.05), -20)
	
	
func _on_Button_pressed():
	if not but1.disabled:
		$SoundClick.play()
		var tween := $TweenStart as Tween
		tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2.5)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)
	
	
func _on_Button2_pressed():
	if not but2.disabled:
		$SoundClick.play()
		var tween := $TweenCredits as Tween
		tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 0.8), 1.0)
		tween.interpolate_property($CanvasLayer/Credits, "self_modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)


func _on_Button3_pressed():
	if not but3.disabled:
		$SoundClick.play()
		var tween := $TweenExit as Tween
		tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 2.5)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)
		
		
func _on_TweenIntro_tween_all_completed():
	but1.set_disabled(false)
	but2.set_disabled(false)
	but3.set_disabled(false)
	
	
func _on_TweenStart_tween_all_completed():
	Controller.reset_flags()
	Controller.collected_hearts.clear()
	get_node("Player").demon_form = false
	get_node("Player").health = 5
	Controller.player_health = 5
	Controller.player_transformed = false
	Controller.goto_scene("res://Scenes/Intro.tscn", Vector2())
	Controller.get_node("MusicHuman").set_volume_db(-14)
	Controller.get_node("MusicDemon").set_volume_db(-14)
	Controller.time = 0.0
	Controller.kills = 0
	Controller.deaths = 0
	
	
func _on_TweenCredits_tween_all_completed():
	if not in_credits:
		in_credits = true
	else:
		in_credits = false
		exited_credits = false
		but1.set_disabled(false)
		but2.set_disabled(false)
		but3.set_disabled(false)
	

func _on_TweenExit_tween_all_completed():
	get_tree().quit()


func _on_TimerIntro_timeout():
	var tween := $TweenIntro as Tween
	tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 1), Color(0, 0, 0, 0), 2)
	tween.start()
