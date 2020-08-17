extends KinematicBody2D

var motion := Vector2()
var speed := 110.0

const blast_ref := preload("res://Prefabs/Blast.tscn")

var active := false
var health := 8
var shielding := false

var first_attack := true
var attacking := false
var in_ground := false
var selected_attack := 0
var turn_to_face := false
var follow := false
var ground_attack := false

var iframes := false

var teleport_target := Vector2()
var move_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var shield := $Shield as Sprite
onready var anim_player_teleport := $AnimationPlayerTeleport as AnimationPlayer
onready var teleport_points = get_tree().get_nodes_in_group("TeleportPoint")
onready var healthbar := get_node("../CanvasLayer/HealthbarBoss") as TextureProgress

onready var player_ref := get_node("../Player") as KinematicBody2D


func _ready():
	var target_point := teleport_points[int(round(rand_range(0, len(teleport_points) - 1)))] as Position2D
	teleport_target = target_point.get_global_position()
	
	
func _process(delta):
	set_z_index(int(get_position().y))
	
	healthbar.set_value(health)
	
	if in_ground:
		if not ground_attack:
			sprite.play("ground")
	elif turn_to_face:
		if iframes:
			sprite.play("ouch_side")
		else:
			var diff := get_position().x - player_ref.get_position().x
			if abs(diff) < 20:
				sprite.play("idle_center" if not attacking else "cast_center")
				sprite.set_flip_h(false)
			else:
				sprite.play("idle_side" if not attacking else "cast_side")
				sprite.set_flip_h(diff > 0)
		
	if in_ground and follow and attacking:
		var player_pos := player_ref.get_position()
		var unit_vector := get_position().direction_to(player_pos).normalized()
		move_target = move_target.linear_interpolate(player_pos + unit_vector * 40, 0.04)
		motion = motion.linear_interpolate(Vector2.RIGHT.rotated(get_position().direction_to(move_target).angle()), 0.1)
	elif not follow:
		motion = Vector2.ZERO
			
			
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
	
	
func hurt(amount: int):
	$SoundHurt.play()
	$SoundHurt2.play()
	health -= amount
	iframes = true
	$TimerTeleport.stop()
	$TimerAttack.stop()
	teleport_start()


func _on_TimerTeleport2_timeout():
	shielding = not shielding
	iframes = false
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
	
	
func display_shield():
	shield.set_visible(shielding and not in_ground)
	
	
func spawn_blast(pos: Vector2, is_ground_attack: bool, direction: float = 0):
	var blast := blast_ref.instance()
	blast.set_position(pos)
	var angle: float = direction if is_ground_attack else get_position().direction_to(player_ref.get_global_position()).angle()
	blast.motion = Vector2.RIGHT.rotated(angle)
	blast.get_node("Sprite").set_rotation(angle)
	blast.get_node("CollisionShape2D").set_rotation(angle)
	blast.set_modulate(Color("#a334f1") if not is_ground_attack else Color.black)
	blast.set_collision_layer_bit(5, false)
	blast.set_collision_mask_bit(5, false)
	blast.set_collision_layer_bit(15, true)
	get_node("..").add_child(blast)


func _on_TimerAttack_timeout():
	$GroundAttackHitbox/CollisionShape2D.set_disabled(true)
	ground_attack = false
	attacking = true
	match selected_attack:
		3:
			follow = true
			$CollisionShape2D.set_disabled(true)
			$TimerGroundAttack.start()
		_:
			for i in range(-1, 2):
				if iframes:
					break
				$SoundBlast.play()
				spawn_blast(get_position() + Vector2(30 * i, 30 * i), false)
				yield(get_tree().create_timer(0.5), "timeout")
			
			if iframes:
				return
				
			$TimerTeleport.set_wait_time(rand_range(0.85, 1.85))
			$TimerTeleport.start()
		#1:
		#	follow = true
		#2:
		#	follow = true
		#3:
		#	follow = true
	

func _on_Hurtbox_body_entered(body):
	if not iframes and not shielding and not in_ground and body.is_in_group("PlayerBlast"):
		hurt(1)
	elif not in_ground:
		$SoundBounce.play()
		body.motion = body.motion.rotated(PI)
		body.get_node("Sprite").rotation_degrees += 180
		body.speed *= 2


func _on_TimerGroundAttack_timeout():
	follow = false
	ground_attack = true
	$GroundAttackHitbox/CollisionShape2D.set_disabled(false)
	$SoundTeleport2.play()
	$SoundBlast.play()
	spawn_blast(get_position() + Vector2(30, 0), true, 0)
	spawn_blast(get_position() + Vector2(0, -30), true, PI / 2)
	spawn_blast(get_position() + Vector2(-30, 30), true, PI)
	spawn_blast(get_position() + Vector2(0, 30), true, (3 * PI) / 2)
	sprite.play("ground2")
	$TimerTeleport.set_wait_time(rand_range(0.85, 1.85))
	$TimerTeleport.start()


func _on_GroundAttackHitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.hurt(1)
