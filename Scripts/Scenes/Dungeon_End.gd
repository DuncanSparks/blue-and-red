extends Node2D

var orbs_destroyed := 0


func _ready():
	if not Controller.boss_cutscene:
		Controller.fadeout_music("MusicDemon", 2.0)
	else:
		Controller.fadeout_music("MusicDemon", 0.1)
		$NPCOsme/AnimationPlayerTalk.play("Talk4")


func initiate_healthbar():
	Controller.boss_cutscene = true
	var tween := $TweenHealthbar as Tween
	tween.interpolate_property($CanvasLayer/HealthbarBoss, "rect_position", Vector2(128, 200), Vector2(128, 162), 4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	
	
func hide_npc():
	$NPCOsme.hide()
	$NPCOsme/CollisionShape2D.set_disabled(true)
	$NPCOsme/AreaInteract/CollisionShape2D.set_disabled(true)
	
	
func increment_orbs():
	if orbs_destroyed < 4:
		orbs_destroyed += 1
		if orbs_destroyed >= 4:
			$BossOsme/Shield2.set_self_modulate(Color(1, 1, 1, 0))
			$BossOsme.ultra_shield = false


func change_npc():
	$NPCOsme.npc_name = "Ivari"
	$NPCOsme.npc_color = Color("#83ff72")
	Cursor.change_mode(false)
	Controller.change_healthbar_color(false)
