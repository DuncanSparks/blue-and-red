extends Position2D

signal enemy_dead

export(int, "Shadow,Demon,Other") var enemy_type: int

const path_demon := "res://Prefabs/Enemies/Demon.tscn"

onready var sound := $SoundSpawn as AudioStreamPlayer
onready var parts1 := $PartsSpawn as Particles2D
onready var parts2 := $PartsSpawn2 as Particles2D


func spawn_enemy():
	sound.play()
	parts1.set_emitting(true)
	parts2.set_emitting(true)
	match enemy_type:
		0:
			pass
		1:
			var demon: KinematicBody2D = (load(path_demon) as PackedScene).instance() as KinematicBody2D
			demon.set_global_position(get_global_position())
			
			get_parent().add_child(demon)
			for con in get_signal_connection_list("enemy_dead"):
				demon.connect("dead", con["target"], con["method"], con["binds"])
		2:
			pass
