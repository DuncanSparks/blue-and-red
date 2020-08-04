extends Node2D

signal enemy_threshold_reached

export(int) var enemy_threshold: int
export(String) var flag_override: String
export(int) var flag_override_value: int

var enemies_defeated := 0


func increment_enemies_defeated():
	enemies_defeated += 1
	if enemies_defeated == enemy_threshold and Controller.flag(flag_override) != flag_override_value:
		emit_signal("enemy_threshold_reached")


func set_flag(flag: String, value: int):
	Controller.set_flag(flag, value)
