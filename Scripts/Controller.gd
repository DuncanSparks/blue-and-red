extends Node2D

signal dialogue_finished

export(Texture) var meter_texture_1: Texture
export(Texture) var meter_texture_2: Texture

export(bool) var start_with_timer := false

const dialogue_ref := preload("res://Prefabs/Dialogue.tscn")
const pause_ref := preload("res://Prefabs/PauseMenu.tscn")

var timer_active := false
var player_transformed := false

var player_health: int = 5

var menu_open := false
var can_pause := false

const flags_initial := {
	"game_start": 0,
	"demon_door_1": 0,
	"demon_door_2": 0,
	"cursed": 0,
	"meet_ivari": 0,
	"demon_door_3": 0,
	"demon_door_4": 0,
	"demon_door_5": 0,
	"demon_door_6": 0,
	"demon_door_7": 0,
	"demon_door_8": 0,
	
	"floorswitch_1": 0,
	"floorswitch_2": 0,
	"floorswitch_3": 0,
	
	"stone_blue": 0,
}

var flags := flags_initial.duplicate(true)

var collected_hearts := {
	
}

onready var player_ref := get_tree().get_root().get_node("Scene/Player") as KinematicBody2D

onready var transform_meter := $UI/CanvasLayer/Clock as TextureProgress
onready var timer_transform := $TimerTransform as Timer


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	if start_with_timer:
		transform_meter.show()
		$UI/CanvasLayer/ClockBack.show()
		timer_transform.start()
		timer_active = true


func _process(delta):
	Cursor.set_cursor_position(get_global_mouse_position())
	
	if timer_active:
		transform_meter.set_value(ceil(timer_transform.get_time_left()))
		
	if Input.is_action_just_pressed("sys_pause") and not menu_open and can_pause and not player_ref.stopped and not player_ref.transforming:
		var pause := pause_ref.instance()
		get_tree().get_root().add_child(pause)
		stop_timer(true)
		menu_open = true
	
	if Input.is_action_just_pressed("debug_2"):
		timer_transform.set_wait_time(0.1)
		timer_transform.start()
		
		
func move_player(position: Vector2):
	player_ref.set_position(position)
	
	
func set_player_transformed(value: bool):
	player_transformed = value
	
	
func fadeout():
	var tween := $CanvasLayer/Tween as Tween
	tween.interpolate_property($CanvasLayer/Fade, "color", Color(0, 0, 0, 0), Color(0, 0, 0, 1), 1.0)
	tween.start()
	
	
func undo_fadeout():
	$CanvasLayer/Fade.color = Color(0, 0, 0, 0)
	
	
func reset_flags():
	flags = flags_initial.duplicate(true)
	
	
func goto_scene(scene: String, player_pos: Vector2):
	get_tree().change_scene(scene)
	yield(get_tree(), "idle_frame")
	player_ref = get_tree().get_root().get_node("Scene/Player") as KinematicBody2D
	move_player(player_pos)
	player_ref.finish_transformation(true, player_transformed)
	player_ref.health = player_health
	
	
func flag(id: String) -> int:
	return flags[id]
	
	
func set_flag(id: String, value: int):
	flags[id] = value
	
	
func fadeout_music(music: NodePath, time: float):
	var mus := get_node(music) as AudioStreamPlayer
	var tween := $TweenMusic as Tween
	tween.interpolate_property(mus, "volume_db", mus.get_volume_db(), -60, time)
	tween.start()
	
	
func initialize_timer():
	player_transformed = false
	transform_meter.set_progress_texture(meter_texture_1)
	var tween := $Tween as Tween
	$UI/CanvasLayer.set_offset(Vector2(0, -50))
	transform_meter.show()
	$UI/CanvasLayer/ClockBack.show()
	tween.interpolate_property($UI/CanvasLayer, "offset", Vector2(0, -50), Vector2(0, 0), 4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	
func uninitialize_timer():
	$UI/CanvasLayer.set_offset(Vector2(0, -50))
	transform_meter.hide()
	$UI/CanvasLayer/ClockBack.hide()
	timer_transform.stop()
	
	
func start_timer():
	timer_active = true
	timer_transform.start()
	
		
func stop_timer(stop: bool, change_mode: int = -1):
	timer_transform.set_paused(stop)
	match change_mode:
		0:
			player_transformed = false
		1:
			player_transformed = true
			
	transform_meter.set_progress_texture(meter_texture_2 if player_transformed else meter_texture_1)
	
	
func play_sound_oneshot(sound: AudioStream, pitch: float = 1.0, volume: float = 0.0):
	var player := AudioStreamPlayer.new()
	player.connect("finished", player, "queue_free")
	player.set_stream(sound)
	player.set_pitch_scale(pitch)
	player.set_volume_db(volume)
	get_tree().get_root().add_child(player)
	player.play()
	
	
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
	player_ref.transformation(player_transformed)
	$TimerPostTransform.start()


func _on_Clock_value_changed(value):
	if value <= 5:
		$SoundTick.play()


func _on_TimerPostTransform_timeout():
	$TimerTransform.set_wait_time(20)
	$TimerTransform.start()


func _on_Tween_tween_all_completed():
	pass # Replace with function body.
