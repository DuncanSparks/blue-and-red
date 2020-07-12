extends StaticBody2D

export(String) var npc_name: String
export(Color) var npc_color: Color
export(int) var max_talk_number := 0
export(bool) var turn_to_face := false

var talk_number := 0

var in_area := false

onready var interact := $Interact as Sprite
onready var player_ref := get_node("../Player") as KinematicBody2D
onready var anim_talk := $AnimationPlayerTalk as AnimationPlayer


func _process(delta):
	if Input.is_action_just_pressed("sys_interact") and in_area and not player_ref.stopped and not player_ref.transforming and not player_ref.pouncing:
		adjust_player()
		Controller.stop_timer(true)
		interact.hide()
		anim_talk.play("Talk" + (str(talk_number + 1) if talk_number > 0 else ""))
			

func adjust_player():
	var spr := player_ref.get_node("Sprite") as AnimatedSprite
	player_ref.stop(true)
	if player_ref.demon_form:
			spr.play("sit_demon")
	
	spr.set_flip_h(player_ref.get_global_position().x > get_global_position().x)
	if turn_to_face:
		$Sprite.set_flip_h(player_ref.get_global_position().x > get_global_position().x)
	player_ref.start_pounce_meter(false)
	
	
func unadjust_player():
	player_ref.stop(false)
	player_ref.start_pounce_meter(player_ref.demon_form)
	
	
func talk_dialogue(text: PoolStringArray, show_name: bool = true):
	anim_talk.stop(false)
	Controller.dialogue(text, npc_name, npc_color, show_name)
	yield(Controller, "dialogue_finished")
	anim_talk.play()
	
	
func talk_set_flag(flag: String, value: int):
	Controller.set_flag(flag, value)
	
	
func talk_fadeout_music(music: String, time: float):
	Controller.fadeout_music(music, time)
	
	
func talk_play_music(music: String):
	Controller.get_node(music).play()
	
	
func talk_initialize_timer():
	Controller.initialize_timer()
	
	
func talk_start_timer():
	Controller.start_timer()
	
	
func talk_set_stone(id: int):
	match id:
		0:
			if Controller.flag("stone_blue") == 1:
				get_node("Stone").show()
				Controller.set_flag("set_stone_blue", 1)
				talk_dialogue(PoolStringArray(["You placed the blue stone on the pedestal."]), false)
			else:
				talk_dialogue(PoolStringArray(["You need the blue stone for this pedestal."]), false)
				talk_number = -1
		1:
			if Controller.flag("stone_purple") == 1:
				get_node("Stone").show()
				Controller.set_flag("set_stone_purple", 1)
				talk_dialogue(PoolStringArray(["You placed the purple stone on the pedestal."]), false)
			else:
				talk_dialogue(PoolStringArray(["You need the purple stone for this pedestal."]), false)
				talk_number = -1
		2:
			get_node("Stone").show()
			Controller.set_flag("set_stone_red", 1)
			talk_dialogue(PoolStringArray(["You placed the red stone on the pedestal."]), false)
	
	
func talk_set_player_transformed(value: bool):
	Controller.set_player_transformed(value)


func _on_AreaInteract_body_entered(body):
	if body.is_in_group("Player") and not body.stopped:
		in_area = true
		interact.show()


func _on_AreaInteract_body_exited(body):
	if body.is_in_group("Player"):
		in_area = false
		interact.hide()


func _on_AnimationPlayerTalk_animation_finished(anim_name):
	if talk_number < max_talk_number:
		talk_number += 1
		
	unadjust_player()
	_on_AreaInteract_body_entered(player_ref)
	Controller.stop_timer(false)
