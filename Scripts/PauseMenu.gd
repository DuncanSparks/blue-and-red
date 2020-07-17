extends Control

export(AudioStream) var hover_sound: AudioStream
export(AudioStream) var click_sound: AudioStream

onready var but1 := $CanvasLayer/VBoxContainer/Button as TextureButton
onready var but2 := $CanvasLayer/VBoxContainer/Button2 as TextureButton
onready var but3 := $CanvasLayer/VBoxContainer/Button3 as TextureButton


func _ready():
	get_tree().set_pause(true)
	var tween := $Tween as Tween
	tween.interpolate_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 0.78), 0.5)
	tween.start()
	
	
func hover():
	if not but1.disabled:
		Controller.play_sound_oneshot(hover_sound, rand_range(0.95, 1.05), -12)
		
		
func _on_Button_pressed():
	if not but1.disabled:
		$SoundClick.play()
		var tween := $Tween3 as Tween
		tween.interpolate_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0.8), Color(0, 0, 0, 0), 0.5)
		tween.interpolate_property($CanvasLayer/VBoxContainer, "rect_position", Vector2(130, 40), Vector2(130, -120), 1.0, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)
	
	
func _on_Button2_pressed():
	if not but2.disabled:
		$SoundClick.play()
		var tween := $Tween4 as Tween
		tween.interpolate_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0.8), Color(0, 0, 0, 1), 1.5)
		tween.interpolate_property($CanvasLayer/VBoxContainer, "rect_position", Vector2(130, 40), Vector2(130, -120), 1.5, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)
		Controller.get_node("MusicHuman").stop()
		Controller.get_node("MusicDemon").stop()


func _on_Button3_pressed():
	if not but3.disabled:
		$SoundClick.play()
		var tween := $Tween5 as Tween
		tween.interpolate_property($CanvasLayer/ColorRect, "color", Color(0, 0, 0, 0.8), Color(0, 0, 0, 1), 2)
		tween.interpolate_property($CanvasLayer/VBoxContainer, "rect_position", Vector2(130, 40), Vector2(130, -120), 2, Tween.TRANS_CUBIC, Tween.EASE_IN)
		tween.start()
		but1.set_disabled(true)
		but2.set_disabled(true)
		but3.set_disabled(true)
		Controller.get_node("MusicHuman").stop()
		Controller.get_node("MusicDemon").stop()


func _on_Tween_tween_all_completed():
	var tween := $Tween2 as Tween
	tween.interpolate_property($CanvasLayer/VBoxContainer, "rect_position", Vector2(130, -120), Vector2(130, 40), 1.0, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()


func _on_Tween2_tween_all_completed():
	but1.set_disabled(false)
	but2.set_disabled(false)
	but3.set_disabled(false)


func _on_Tween3_tween_all_completed():
	get_tree().set_pause(false)
	Controller.menu_open = false
	Controller.stop_timer(false)
	Controller.run_speedrun_stats = true
	queue_free()


func _on_Tween4_tween_all_completed():
	get_tree().set_pause(false)
	Controller.menu_open = false
	Controller.goto_scene("res://Scenes/Title.tscn", Vector2())
	Controller.uninitialize_timer()
	queue_free()


func _on_Tween5_tween_all_completed():
	get_tree().quit()

