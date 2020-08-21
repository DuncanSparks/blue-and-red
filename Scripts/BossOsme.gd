extends KinematicBody2D

var motion := Vector2()
var speed := 100.0

const blast_ref := preload("res://Prefabs/Blast.tscn")
const spike_ref := preload("res://Prefabs/Enemies/OsmeSpike.tscn")

var active := false
var health := 8
var shielding := false

var attack_count := 0

var first_attack := true
var attacking := false
var in_ground := false
var selected_attack := 0
var turn_to_face := false
var follow := false
var ground_attack := false
var drop_shield := true
var ultra_move := false
var ultra_shield := false

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
	
	if in_ground and health > 0:
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
	$TimerTeleport2.start()
	turn_to_face = false
	
	
func hurt(amount: int):
	$SoundHurt.play()
	$SoundHurt2.play()
	$PartsHurt.set_emitting(true)
	health -= amount
	iframes = true
	$TimerTeleport.stop()
	$TimerAttack.stop()
	if health > 0:
		teleport_start()
	else:
		Controller.run_speedrun_stats = false
		$SoundDie.play()
		$SoundDie2.play()
		$PartsHurt.set_one_shot(false)
		$PartsHurt.set_emitting(true)
		get_node("../MusicBoss").stop()
		healthbar.hide()
		
		var player := get_node("../Player") as KinematicBody2D
		player.disable_pounce(true)
		player.stop(true)
		if player.demon_form:
			player.get_node("Sprite").play("sit_demon")
		
		player_ref.start_pounce_meter(false)
		
		Controller.game_ended = true
		Controller.stop_timer_end()
		Controller.uninitialize_timer()
		yield(get_tree().create_timer(3.0), "timeout")
		get_node("../NPCOsme/AnimationPlayerTalk").play("Talk3")


func _on_TimerTeleport2_timeout():
	attack_count += 1
	shielding = true
	ground_attack = false
	drop_shield = not drop_shield
	iframes = false
	selected_attack = int(round(rand_range(0, 2))) if health < 5 and not ultra_move else int(round(rand_range(0, 6))) if attack_count > 2 else int(round(rand_range(0, 2))) if not first_attack else 0
	if first_attack:
		first_attack = false
		
	in_ground = selected_attack == 3
	if health < 5 and not ultra_move:
		ultra_shield = true
		if in_ground:
			in_ground = false
		
	if ultra_shield:	
		$Shield2.show()
		
	anim_player_teleport.play("In")
	set_global_position(teleport_target)
	$CollisionShape2D.set_disabled(false)
	$Hurtbox/CollisionShape2D.set_disabled(false)
	iframes = false
	$TimerAttack.set_wait_time(rand_range(0.78, 1.5))
	$TimerAttack.start()
	turn_to_face = true
	
	
func spawn_blast(pos: Vector2, is_ground_attack: bool, direction: float = 0, homing: bool = true):
	var blast := blast_ref.instance()
	blast.set_position(pos)
	var angle: float = direction if is_ground_attack or not homing else get_position().direction_to(player_ref.get_global_position()).angle()
	blast.motion = Vector2.RIGHT.rotated(angle)
	if not homing:
		blast.speed *= 0.5
	blast.get_node("Sprite").set_rotation(angle)
	blast.get_node("CollisionShape2D").set_rotation(angle)
	blast.set_modulate(Color("#a334f1"))
	blast.set_collision_layer_bit(5, false)
	blast.set_collision_mask_bit(5, false)
	blast.set_collision_layer_bit(15, true)
	get_node("..").add_child(blast)


func _on_TimerAttack_timeout():
	$GroundAttackHitbox/CollisionShape2D.set_disabled(true)
	attacking = true
	if health < 5 and not ultra_move:
		ultra_move = true
		get_node("../OrbBlue").spawn()
		yield(get_tree().create_timer(0.4), "timeout")
		get_node("../OrbBlue2").spawn()
		yield(get_tree().create_timer(0.4), "timeout")
		get_node("../OrbRed").spawn()
		yield(get_tree().create_timer(0.4), "timeout")
		get_node("../OrbRed2").spawn()
		yield(get_tree().create_timer(0.4), "timeout")
		
		$TimerTeleport.set_wait_time(rand_range(0.85, 1.85))
		$TimerTeleport.start()
	else:
		match selected_attack:
			3:
				follow = true
				$CollisionShape2D.set_disabled(true)
				$Hurtbox/CollisionShape2D.set_disabled(false)
				$TimerGroundAttack.start()
			0,4:
				$TimerDropShield.start()
				for i in range(-1, 2):
					if iframes:
						break
					$SoundBlast.play()
					spawn_blast(get_position() + Vector2(30 * i, 30 * i), false)
					yield(get_tree().create_timer(0.5), "timeout")
				
				if iframes:
					return
					
				$TimerTeleport.set_wait_time(rand_range(1.2, 1.8))
				$TimerTeleport.start()
			1,5:
				$TimerDropShield.start()
				for i in range(4):
					if iframes:
						break
					$SoundBlast.play()
					spawn_blast(Vector2(-6 if i % 2 == 0 else 326, rand_range(20, 160)), false, 0.0 if i % 2 == 0 else PI, false)
					yield(get_tree().create_timer(0.5), "timeout")
					
				if iframes:
					return
					
				$TimerTeleport.set_wait_time(rand_range(1.5, 2.2))
				$TimerTeleport.start()
				
			2,6:
				$TimerDropShield.start()
				$SoundTeleport2.play()
				$SoundSpell.play()
				for _i in range(4):
					var spike := spike_ref.instance() as Area2D
					spike.set_position(Vector2(rand_range(48, 272), rand_range(64, 140)))
					get_node("..").add_child(spike)

				$TimerTeleport.set_wait_time(rand_range(1.5, 2.2))
				$TimerTeleport.start()


func _on_Hurtbox_body_entered(body):
	if not iframes and not ultra_shield and body.is_in_group("PlayerBlast"):
		if in_ground or not shielding:
			hurt(1)
		elif not in_ground:
			$SoundBounce.play()
			body.motion = body.motion.rotated(PI)
			body.get_node("Sprite").rotation_degrees += 180
			body.speed *= 2
	elif not in_ground:
		$SoundBounce.play()
		body.motion = body.motion.rotated(PI)
		body.get_node("Sprite").rotation_degrees += 180
		body.speed *= 2
		
		
func _on_Hurtbox_area_entered(area):
	if area.is_in_group("PlayerPounce"):
		if not iframes and not shielding and not ultra_shield and not in_ground:
			hurt(3)
		elif not in_ground:
			$SoundBounce.play()


func _on_TimerGroundAttack_timeout():
	follow = false
	ground_attack = true
	$GroundAttackHitbox/CollisionShape2D.set_disabled(false)
	$Hurtbox/CollisionShape2D.set_disabled(false)
	$SoundTeleport2.play()
	$SoundBlast.play()
	spawn_blast(get_position() + Vector2(30, 0), true, 0)
	spawn_blast(get_position() + Vector2(0, -30), true, PI / 2)
	spawn_blast(get_position() + Vector2(-30, 0), true, PI)
	spawn_blast(get_position() + Vector2(0, 30), true, (3 * PI) / 2)
	sprite.play("ground2")
	$TimerTeleport.set_wait_time(rand_range(0.85, 1.85))
	$TimerTeleport.start()


func _on_TimerDropShield_timeout():
	if drop_shield:
		shielding = false
		$AnimationPlayerShield2.play("Shield Fade")
