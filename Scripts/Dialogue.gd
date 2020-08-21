extends Control

signal dialogue_finished

export(AudioStream) var text_sound: AudioStream
export(Texture) var box_texture_1: Texture
export(Texture) var box_texture_2: Texture

const regex_pat := "\\[.*?\\]"
var regex := RegEx.new()

var dialogue := []
var dialogue_page := 0
var page_length := 0

var allow_advance := false

onready var name_label := $CanvasLayer/Box/Name as Label
onready var text := $CanvasLayer/Box/Text as RichTextLabel

func _ready():
	regex.compile(regex_pat)
	
	
func _process(delta):
	if Input.is_action_just_pressed("sys_interact") or Input.is_action_just_pressed("attack"):
		if allow_advance:
			if dialogue_page < len(dialogue) - 1:
				dialogue_page += 1
				text.set_visible_characters(0)
				text.set_bbcode(dialogue[dialogue_page])
				page_length = len(strip(dialogue[dialogue_page]))
				allow_advance = false
				$TimerText.start()
			else:
				emit_signal("dialogue_finished")
				queue_free()
		else:
			text.set_visible_characters(len(dialogue[dialogue_page]) + 1)
	
	
func start_dialogue(text_input: Array, name: String, name_color: Color, show_name: bool = true):
	dialogue = text_input
	name_label.set_text(name)
	name_label.set_visible(show_name)
	name_label.set_self_modulate(name_color)
	text.set_bbcode(dialogue[0])
	page_length = len(strip(dialogue[0]))
	$CanvasLayer/Box.show()
	$TimerText.start()
	
	
func strip(string: String):
	return regex.sub(string, "", true)
	
	
func set_box_texture(texture: int):
	match texture:
		0:
			$CanvasLayer/Box.set_texture(box_texture_1)
		1:
			$CanvasLayer/Box.set_texture(box_texture_2)


func _on_TimerText_timeout():
	var chars := text.get_visible_characters()
	text.set_visible_characters(chars + 1)
	if chars + 1 < page_length:
		Controller.play_sound_oneshot(text_sound, rand_range(0.98, 1.02), -18)
	if chars + 1 >= len(dialogue[dialogue_page]):
		$TimerText.stop()
		allow_advance = true
