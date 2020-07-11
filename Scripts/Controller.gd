extends Node

export(Texture) var meter_texture_1: Texture
export(Texture) var meter_texture_2: Texture

var player_transformed := false

onready var player_ref := get_tree().get_root().get_node("Scene/Player") as KinematicBody2D

onready var transform_meter := $UI/CanvasLayer/Clock as TextureProgress
onready var timer_transform := $TimerTransform


func _process(delta):
	transform_meter.set_value(ceil(timer_transform.get_time_left()))
	
	if Input.is_action_just_pressed("debug_2"):
		timer_transform.set_wait_time(0.1)
		timer_transform.start()


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
