extends KinematicBody2D

var motion := Vector2()

var active := false
var health := 16
var shielding := true

var attacking := false
var turn_to_face := false

var iframes := false

var teleport_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var shield := $Shield as Sprite
onready var anim_player_teleport := $AnimationPlayerTeleport as AnimationPlayer
onready var teleport_points = get_tree().get_nodes_in_group("TeleportPoint")

onready var player_ref := get_node("../Player") as KinematicBody2D


func _ready():
	var target_point := teleport_points[int(round(rand_range(0, len(teleport_points) - 1)))] as Position2D
	teleport_target = target_point.get_global_position()
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	if turn_to_face and not attacking:
		var diff := get_position().x - player_ref.get_position().x
		if abs(diff) < 20:
			sprite.play("idle_center")
			sprite.set_flip_h(false)
		else:
			sprite.play("idle_side")
			sprite.set_flip_h(diff > 0)
			


func initialize():
	active = true
	_on_TimerTeleport2_timeout()
	
	
func teleport_start():
	anim_player_teleport.play("Out")
	

func teleport():
	var target_point := teleport_points[int(round(rand_range(0, len(teleport_points) - 1)))] as Position2D
	teleport_target = target_point.get_global_position()
	$CollisionShape2D.set_disabled(true)
	$Hurtbox/CollisionShape2D.set_disabled(true)
	#$ParticlesTeleport.set_emitting(true)
	#sprite.hide()
	#shield.hide()
	#$SoundTeleport.play()
	$TimerTeleport2.start()
	turn_to_face = false


func _on_TimerTeleport2_timeout():
	anim_player_teleport.play("In")
	#sprite.play("idle")
	set_global_position(teleport_target)
	#$SoundTeleport.play()
	#$Healthbar.hide()
	$CollisionShape2D.set_disabled(false)
	$Hurtbox/CollisionShape2D.set_disabled(false)
	#$ParticlesTeleport2.set_emitting(true)
	#sprite.show()
	iframes = false
	$TimerAttack.set_wait_time(rand_range(0.78, 1.5))
	$TimerAttack.start()
	turn_to_face = true


func _on_TimerAttack_timeout():
	pass # Replace with function body.
