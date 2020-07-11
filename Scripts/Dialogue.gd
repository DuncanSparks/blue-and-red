extends Control

signal dialogue_finished

var dialogue := []
var dialogue_page := 0

var allow_advance := false

onready var name_label := $CanvasLayer/Box/Name as Label
onready var text := $CanvasLayer/Box/Text as RichTextLabel

func _ready():
	pass # Replace with function body.
	
	
func _process(delta):
	if Input.is_action_just_pressed("sys_interact"):
		if allow_advance:
			if dialogue_page < len(dialogue) - 1:
				dialogue_page += 1
				text.set_visible_characters(0)
				text.set_bbcode(dialogue[dialogue_page])
				$TimerText.start()
			else:
				emit_signal("dialogue_finished")
				queue_free()
	
	
func start_dialogue(text_input: Array, name: String, name_color: Color, show_name: bool = true):
	dialogue = text_input
	name_label.set_text(name)
	name_label.set_visible(show_name)
	name_label.set_self_modulate(name_color)
	text.set_bbcode(dialogue[0])
	$CanvasLayer/Box.show()
	$TimerText.start()


func _on_TimerText_timeout():
	var chars := text.get_visible_characters()
	text.set_visible_characters(chars + 1)
	if chars + 1 >= len(dialogue[dialogue_page]):
		$TimerText.stop()
		allow_advance = true
