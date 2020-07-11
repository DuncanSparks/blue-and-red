extends Node

export(Texture) var meter_texture_1: Texture
export(Texture) var meter_texture_2: Texture

var player_transformed := false

onready var player_ref := get_node("../Player") as KinematicBody2D

onready var transform_meter := $UI/Clock as TextureProgress
onready var timer_transform := $TimerTransform


func _ready():
	pass # Replace with function body.


func _process(delta):
	transform_meter.set_value(ceil(timer_transform.get_time_left()))


func _on_TimerTransform_timeout():
	player_transformed = not player_transformed
	$SoundTick.play()
	$SoundBell.play()
	transform_meter.set_progress_texture(meter_texture_2 if player_transformed else meter_texture_1)
	player_ref.transform(true)


func _on_Clock_value_changed(value):
	if value <= 5:
		$SoundTick.play()
			
