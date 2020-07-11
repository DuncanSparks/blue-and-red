extends StaticBody2D

export(String) var npc_name: String
export(Color) var npc_color: Color
export(int) var max_talk_number := 0

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
	player_ref.start_pounce_meter(false)
	
	
func unadjust_player():
	player_ref.stop(false)
	player_ref.start_pounce_meter(player_ref.demon_form)
	
	
func talk_dialogue(text: PoolStringArray, show_name: bool = true):
	anim_talk.stop(false)
	Controller.dialogue(text, npc_name, npc_color, show_name)
	yield(Controller, "dialogue_finished")
	anim_talk.play()
	
	
func talk_initialize_timer():
	Controller.initialize_timer()
	
	
func talk_start_timer():
	Controller.start_timer()


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
