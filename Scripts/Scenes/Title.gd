extends Control

export(AudioStream) var hover_sound: AudioStream
export(AudioStream) var click_sound: AudioStream

var in_credits := false
var exited_credits := false

onready var but1 := $HBoxContainer/Button as TextureButton
onready var but2 := $HBoxContainer/Button2 as TextureButton
onready var but3 := $HBoxContainer/Button3 as TextureButton


func _process(delta):
	if in_credits and not exited_credits and Input.is_action_just_pressed("attack"):
		var tween := $TweenCredits as Tween
		tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0.8), Color(0, 0, 0, 0), 1.0)
		tween.interpolate_property($CanvasLayer/Credits, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1.0)
		tween.start()
		exited_credits = true
	
	
func hover():
	if not but1.disabled:
		Controller.play_sound_oneshot(hover_sound, rand_range(0.95, 1.05), -12)
	
	
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



