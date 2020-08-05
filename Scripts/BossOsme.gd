extends KinematicBody2D

var motion := Vector2()
var speed := 100.0

const blast_ref := preload("res://Prefabs/Blast.tscn")

var active := false
var health := 16
var shielding := true

var first_attack := true
var attacking := false
var in_ground := false
var selected_attack := 0
var turn_to_face := false
var follow := false

var iframes := false

var teleport_target := Vector2()
var move_target := Vector2()

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
	
	if in_ground:
		sprite.play("ground")
	elif turn_to_face:
		var diff := get_position().x - player_ref.get_position().x
		if abs(diff) < 20:
			sprite.play("idle_center" if not attacking else "cast_center")
			sprite.set_flip_h(false)
		else:
			sprite.play("idle_side" if not attacking else "cast_side")
			sprite.set_flip_h(diff > 0)
		
	if in_ground and attacking:
		var player_pos := player_ref.get_position()
		var unit_vector := get_position().direction_to(player_pos).normalized()
		move_target = move_target.linear_interpolate(player_pos + unit_vector * 40, 0.02)
		motion = motion.linear_interpolate(Vector2.RIGHT.rotated(get_position().direction_to(move_target).angle()), 0.05)
			
			
func _physics_process(delta):
	if in_ground:
		move_and_slide(motion * speed)
			

func initialize():
	active = true
	add_to_group("Enemy")
	_on_TimerTeleport2_timeout()
	
	
func teleport_start():
	attacking = false
	anim_player_teleport.play("Out")
	
	
func show_shield():
	if not in_ground:
		shield.show()
	

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
	selected_attack = int(round(rand_range(0, 3))) if not first_attack else 0
	if first_attack:
		first_attack = false
		
	in_ground = selected_attack == 3
		
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
	attacking = true
	match selected_attack:
		0:
			$SoundBlast.play()
			var blast := blast_ref.instance()
			blast.set_position(get_position())
			var angle := get_position().direction_to(player_ref.get_global_position()).angle()
			blast.motion = Vector2.RIGHT.rotated(angle)
			blast.get_node("Sprite").set_rotation(angle)
			blast.get_node("CollisionShape2D").set_rotation(angle)
			blast.set_modulate(Color("#a334f1"))
			blast.set_collision_layer_bit(5, false)
			blast.set_collision_mask_bit(5, false)
			blast.set_collision_layer_bit(15, true)
			get_node("..").add_child(blast)
			$TimerTeleport.set_wait_time(rand_range(0.85, 1.85))
			$TimerTeleport.start()
		1:
			continue
		2:
			continue
		3:
			follow = true
	
	
