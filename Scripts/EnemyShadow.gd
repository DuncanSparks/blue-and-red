extends KinematicBody2D

signal dead

const blast_ref := preload("res://Prefabs/Blast.tscn")

var health := 3
var attacking := false
var pouncing := false
var stunned := false
var iframes := false
var dead := false

var teleport_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var player_ref := get_node("../Player") as KinematicBody2D
onready var teleport_points = get_tree().get_nodes_in_group("TeleportPoint")

func _ready():
	$TimerAttack.set_wait_time(rand_range(0.78, 1.5))
	$TimerAttack.start()


func _process(delta):
	set_z_index(int(get_position().y))


func attack():
	if get_global_position().x >= player_ref.get_global_position().x:
		sprite.set_flip_h(true)
	else:
		sprite.set_flip_h(false)
	
	sprite.play("cast")
	$SoundBlast.play()
	
	var blast := blast_ref.instance() as KinematicBody2D
	blast.set_position(get_position())
	var angle := get_position().direction_to(player_ref.get_global_position()).angle()
	blast.motion = Vector2.RIGHT.rotated(angle)
	blast.get_node("Sprite").set_rotation(angle)
	blast.get_node("CollisionShape2D").set_rotation(angle)
	blast.set_modulate(Color(0, 0, 0, 1))
	blast.set_collision_layer_bit(5, false)
	blast.set_collision_mask_bit(5, false)
	blast.set_collision_layer_bit(15, true)
	blast.set_collision_mask_bit(15, true)
	get_node("..").add_child(blast)
	
	$TimerTeleport.start()
	
	
func teleport():
	var target_point := teleport_points[int(round(rand_range(0, len(teleport_points) - 1)))] as Position2D
	teleport_target = target_point.get_global_position()
	$CollisionShape2D.set_disabled(true)
	$Hurtbox/CollisionShape2D.set_disabled(true)
	$ParticlesTeleport.set_emitting(true)
	sprite.hide()
	$SoundTeleport.play()
	#hide()
	$TimerTeleport2.start()
	
	
func hurt(amount: int):
	$SoundHurt.play()
	sprite.play("hurt")
	health -= amount
	$Healthbar.set_value(health)
	$TimerTeleport.stop()
	$TimerAttack.stop()
	if health > 0:
		$Healthbar.show()
		#$AnimationPlayer.play("Iframes")
		$TimerHurt.start()
	else:
		$SoundDie.play()
		$ParticlesDeath.set_emitting(true)
		$CollisionShape2D.call_deferred("set_disabled", true)\
		
		var tween := $TweenFade as Tween
		tween.interpolate_property(sprite, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.42)
		tween.start()
		dead = true
		$TimerDeath.start()
		emit_signal("dead")


func _on_TimerAttack_timeout():
	attack()


func _on_TimerTeleport_timeout():
	teleport()


func _on_TimerTeleport2_timeout():
	sprite.play("idle")
	set_global_position(teleport_target)
	$SoundTeleport.play()
	$Healthbar.hide()
	$CollisionShape2D.set_disabled(false)
	$Hurtbox/CollisionShape2D.set_disabled(false)
	$ParticlesTeleport2.set_emitting(true)
	sprite.show()
	$TimerAttack.set_wait_time(rand_range(0.78, 1.5))
	$TimerAttack.start()


func _on_Hurtbox_body_entered(body):
	if body.is_in_group("Blast") and not iframes and not dead:
		hurt(1)


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("PlayerPounce") and not iframes and not dead:
		hurt(3)
