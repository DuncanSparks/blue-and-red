extends Position2D

# warning-ignore:unused_signal
signal enemy_dead

export(int, "Shadow,Demon,Other") var enemy_type: int

const path_demon := "res://Prefabs/Enemies/Demon.tscn"
const path_shadow := "res://Prefabs/Enemies/Shadow.tscn"

onready var sound := $SoundSpawn as AudioStreamPlayer
onready var sound2 := $SoundSpawn2 as AudioStreamPlayer
onready var parts1 := $PartsSpawn as Particles2D
onready var parts2 := $PartsSpawn2 as Particles2D


func _process(delta):
	var pause := true
	for node in get_node("..").get_children():
		if node.is_in_group("Enemy"):
			pause = false
			break
			
	Controller.timer_transform.set_paused(pause)
		

func spawn_enemy():
	sound.play()
	parts1.set_emitting(true)
	$Timer.start()
	

func spawn_enemy_2():
	sound2.play()
	parts2.set_emitting(true)
	match enemy_type:
		0:
			var shadow: KinematicBody2D = (load(path_shadow) as PackedScene).instance() as KinematicBody2D
			shadow.set_global_position(get_global_position())
			
			get_parent().add_child(shadow)
			for con in get_signal_connection_list("enemy_dead"):
				shadow.connect("dead", con["target"], con["method"], con["binds"])
		1:
			var demon: KinematicBody2D = (load(path_demon) as PackedScene).instance() as KinematicBody2D
			demon.set_global_position(get_global_position())
			
			get_parent().add_child(demon)
			for con in get_signal_connection_list("enemy_dead"):
				demon.connect("dead", con["target"], con["method"], con["binds"])
		2:
			pass
