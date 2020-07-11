extends Node

signal dialogue_finished

export(Texture) var meter_texture_1: Texture
export(Texture) var meter_texture_2: Texture

const dialogue_ref := preload("res://Prefabs/Dialogue.tscn")

var player_transformed := false

var flags := {
	"game_start": 0,
}

onready var player_ref := get_tree().get_root().get_node("Scene/Player") as KinematicBody2D

onready var transform_meter := $UI/CanvasLayer/Clock as TextureProgress
onready var timer_transform := $TimerTransform as Timer


func _process(delta):
	transform_meter.set_value(ceil(timer_transform.get_time_left()))
	
	if Input.is_action_just_pressed("debug_2"):
		timer_transform.set_wait_time(0.1)
		timer_transform.start()
		
		
func move_player(position: Vector2):
	player_ref.set_position(position)
	
	
func goto_scene(scene: String, player_pos: Vector2):
	get_tree().change_scene(scene)
	yield(get_tree(), "idle_frame")
	player_ref = get_tree().get_root().get_node("Scene/Player") as KinematicBody2D
	move_player(player_pos)
	player_ref.finish_transformation(true, player_transformed)
	
	
func flag(id: String) -> int:
	return flags[id]
	
	
func set_flag(id: String, value: int):
	flags[id] = value
		
		
func stop_timer(stop: bool, change_mode: int = -1):
	timer_transform.set_paused(stop)
	match change_mode:
		0:
			player_transformed = false
		1:
			player_transformed = true
			
	transform_meter.set_progress_texture(meter_texture_2 if player_transformed else meter_texture_1)
	
	
func dialogue(text: Array, name_: String, color: Color, show_name: bool = true):
	var dlg := dialogue_ref.instance()
	get_tree().get_root().add_child(dlg)
	dlg.start_dialogue(text, name_, color, show_name)
	yield(dlg, "dialogue_finished")
	emit_signal("dialogue_finished")


func _on_TimerTransform_timeout():
	timer_transform.stop()
	player_transformed = not player_transformed
	$SoundTick.play()
	$SoundTransform.play()
	$SoundBell.play()
	transform_meter.set_progress_texture(meter_texture_2 if player_transformed else meter_texture_1)
	player_ref.transform(player_transformed)
	$TimerPostTransform.start()


func _on_Clock_value_changed(value):
	if value <= 5:
		$SoundTick.play()


func _on_TimerPostTransform_timeout():
	$TimerTransform.set_wait_time(20)
	$TimerTransform.start()
