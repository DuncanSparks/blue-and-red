extends Control

export(AudioStream) var text_sound: AudioStream

const dialogue := [
	"To my \"favorite\" student:",
	"I'm not sure why you did so poorly on the recent sorcery exam, but you'll be glad to know I have an opportunity for you to raise your grade.",
	"The city council has informed me that the demon lord Osme (Yes, THE Osme) is at it again.",
	"I know, right? I think this is the fifth time this year.",
	"They need someone to go and seal him away again, but all their sorcerers are too busy with other matters. They approached me asking if I had any students who would be willing to help.",
	"Look... I know you're not the greatest sorcery student (No offense), but I think you have a lot of potential, and I have this feeling in my gut that you can do it.",
	"You can stop Osme and put an end to our troubles. For a few months, at least.",
	"And if you do, I think I can turn that D+ into an A+. It's a win for everyone.",
	"What do you think?"	
]


var page := 0
var page_length := 0
var allow_advance := true

onready var text := $Text as Label


func _ready():
	Controller.undo_fadeout()
	$TimerStart.start()
	
	
func _process(delta):
	if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("sys_interact"):
		if allow_advance:
			if page < len(dialogue) - 1:
				text.set_visible_characters(0)
				allow_advance = false
				page += 1
				text.set_text(dialogue[page])
				page_length = len(dialogue[page].replace(" ", ""))
				$TimerText.start()
			else:
				allow_advance = false
				text.hide()
				$Skip.hide()
				$TimerEnd.start()
		else:
			text.set_visible_characters(len(dialogue[page]) + 1)
			
	if Input.is_action_just_pressed("sys_pause"):
		$TimerText.stop()
		allow_advance = false
		text.hide()
		$Skip.hide()
		$TimerEnd.start()


func _on_TimerStart_timeout():
	text.set_text(dialogue[0])
	page_length = len(dialogue[0].replace(" ", ""))
	$TimerText.start()
	var tween := $Tween as Tween
	tween.interpolate_property($Skip, "self_modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 3.0)
	tween.start()


func _on_TimerText_timeout():
	var chars := text.get_visible_characters()
	text.set_visible_characters(chars + 1)
	if chars + 1 < page_length:
		Controller.play_sound_oneshot(text_sound, rand_range(0.98, 1.02), -26)
	if chars + 1 >= len(dialogue[page]):
		$TimerText.stop()
		allow_advance = true


func _on_TimerEnd_timeout():
	Controller.get_node("MusicHuman").play()
	Controller.can_pause = true
	Controller.run_speedrun_stats = true
	Controller.get_node("CanvasLayer2/Time").show()
	Controller.can_pause = true
	Controller.goto_scene("res://Scenes/Dungeon/Dungeon_Entrance1.tscn", Vector2(160, 158))
