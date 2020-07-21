extends KinematicBody2D

var motion := Vector2()

var health := 16
var shielding := true

var teleport_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var shield := $Shield as Sprite
onready var teleport_points = get_tree().get_nodes_in_group("TeleportPoint")

func _ready():
	pass


func teleport():
	var target_point := teleport_points[int(round(rand_range(0, len(teleport_points) - 1)))] as Position2D
	teleport_target = target_point.get_global_position()
	$CollisionShape2D.set_disabled(true)
	$Hurtbox/CollisionShape2D.set_disabled(true)
	$ParticlesTeleport.set_emitting(true)
	sprite.hide()
	shield.hide()
	$SoundTeleport.play()
	#hide()
	$TimerTeleport2.start()
