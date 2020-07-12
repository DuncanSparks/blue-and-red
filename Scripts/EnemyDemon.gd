extends KinematicBody2D

signal dead

export(bool) var path_to_player := true
export(Texture) var flame_texture: Texture

const flame_ref := preload("res://Prefabs/Orb.tscn")

var motion := Vector2()
var speed := 70

var health := 3
var attacking := false
var pouncing := false
var stunned := false
var iframes := false
var dead := false

var can_swipe := true
var can_flame := false
var can_pounce := false
var pounce_target := Vector2()

var nav_path: PoolVector2Array = []
var nav_node: Navigation2D = null
var player_ref: KinematicBody2D = null

onready var sprite := $Sprite as AnimatedSprite
onready var sound_hurt := $SoundHurt as AudioStreamPlayer
onready var healthbar := $Healthbar as TextureProgress
onready var swipe_box := $SwipeBox/CollisionShape2D as CollisionShape2D

func _ready():
	nav_node = get_node("../Navigation2D")
	player_ref = get_node("../Player")
	if path_to_player:
		nav_path = nav_node.get_simple_path(get_global_position(), player_ref.get_global_position(), true)
		$TimerNav.start()
		
	$TimerStartPounce.set_wait_time(rand_range(0.8, 2))
	$TimerStartFlame.set_wait_time(rand_range(3.5, 6))
	$TimerStartPounce.start()
	$TimerStartFlame.start()
	
		
func _process(delta):
	set_z_index(int(get_position().y))
	
	if not stunned and not attacking and not dead:
		if path_to_player:
			move_along_path(speed * delta)
		
		sprite_management()
	
	var distance_to_player := get_global_position().distance_to(player_ref.get_global_position())
	
	if not attacking and can_flame and not dead:
		flame()
	
	if distance_to_player <= 60 and not attacking and can_pounce and not dead:
		pounce()
		
	if distance_to_player <= 20 and not attacking and can_swipe and not dead:
		swipe()
		
		
func _physics_process(delta):
	move_and_slide(motion * speed)

	
func swipe():
	attacking = true
	motion = Vector2.ZERO
	sprite.play("swipe")
	$SoundSwipe.play()
	swipe_box.set_disabled(false)
	can_swipe = false
	$TimerSwipe.start()
	
	
func pounce():
	attacking = true
	motion = Vector2.ZERO
	sprite.play("pounce")
	can_pounce = false
	pounce_target = player_ref.get_global_position()
	$TimerPounce.start()
	
	
func flame():
	attacking = true
	motion = Vector2.ZERO
	sprite.play("flame")
	can_flame = false
	$TimerFlame.start()
	
	
func hurt(amount: int):
	sound_hurt.play()
	$SoundHurt2.play()
	sprite.play("ouch")
	health -= amount
	healthbar.set_value(health)
	stunned = true
	motion = Vector2.ZERO
	if health <= 0:
		$SoundDie.play()
		$ParticlesDeath.set_emitting(true)
		$CollisionShape2D.call_deferred("set_disabled", true)
		$SwipeBox/CollisionShape2D.call_deferred("set_disabled", true)
		$PounceBox/CollisionShape2D.call_deferred("set_disabled", true)
		$Hurtbox/CollisionShape2D.call_deferred("set_disabled", true)
		var tween := $TweenFade as Tween
		tween.interpolate_property(sprite, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.42)
		tween.start()
		dead = true
		$TimerDeath.start()
		Controller.kills += 1
		emit_signal("dead")
	else:
		healthbar.show()
		iframes = true
		$TimerStun.start()
		$AnimationPlayer.play("Iframes")


func move_along_path(distance: float):
	var start_point := get_global_position()
	for _i in range(nav_path.size()):
		var dist := start_point.distance_to(nav_path[0])
		if distance <= dist and dist >= 0:
			var angle = get_angle_to(nav_path[0])
			motion = Vector2(cos(angle), sin(angle))
			break
		distance -= dist
		start_point = nav_path[0]
		nav_path.remove(0)
		
		
func sprite_management():
	sprite.play("run" if is_moving() else "idle")
	
	if motion.x < 0:
		sprite.set_flip_h(true)
		swipe_box.set_position(Vector2(-17, 2))
	elif motion.x > 0:
		sprite.set_flip_h(false)
		swipe_box.set_position(Vector2(17, 2))
		
		
func is_moving() -> bool:
	return motion != Vector2.ZERO


func _on_TimerNav_timeout():
	nav_path = nav_node.get_simple_path(get_global_position(), player_ref.get_global_position(), false)


func _on_Hurtbox_body_entered(body):
	if body.is_in_group("Blast") and not iframes and not dead:
		hurt(1)


func _on_Hurtbox_area_entered(area):
	if area.is_in_group("PlayerPounce") and not iframes and not dead:
		hurt(3)
	
	
func _on_TimerStartPounce_timeout():
	can_pounce = true


func _on_TimerStun_timeout():
	stunned = false


func _on_TimerAttack_timeout():
	attacking = false


func _on_TimerPounce_timeout():
	if not dead:
		speed = 200
		motion = Vector2.RIGHT.rotated(get_global_position().direction_to(pounce_target).angle())
		$SoundPounce.play()
		pouncing = true
		$PounceBox/CollisionShape2D.set_disabled(false)
		$TimerPounce2.start()


func _on_TimerPounce2_timeout():
	motion = Vector2.ZERO
	pouncing = false
	speed = 70
	if not dead:
		$SoundLand.play()
		sprite.play("land")
		$PartsLand.set_emitting(true)
		$PounceBox/CollisionShape2D.set_disabled(true)
		$TimerPounce3.start()
		$TimerStartPounce.set_wait_time(rand_range(1, 2.8))
		$TimerStartPounce.start()


func _on_TimerFlame_timeout():
	if not dead:
		$SoundFlame.play()
		sprite.play("flame_2")
		var flame_inst := flame_ref.instance() as KinematicBody2D
		flame_inst.set_position(get_global_position())
		flame_inst.motion = Vector2.RIGHT.rotated(get_position().direction_to(player_ref.get_global_position()).angle())
		flame_inst.get_node("AnimatedSprite").play("idle_flame")
		flame_inst.set_scale(Vector2(1.5, 1.5))
		#$flame_inst.set_collision_layer_bit(15, true)
		#$flame_inst.set_collision_mask_bit(15, true)
		#flame_inst.set_collision_layer_bit(5, false)
		#flame_inst.set_collision_mask_bit(5, false)
		flame_inst.grow()
		flame_inst.speed = 200
		get_node("..").add_child(flame_inst)
		$TimerFlame2.start()
		$TimerStartFlame.set_wait_time(rand_range(2.5, 4))
		$TimerStartFlame.start()


func _on_TimerStartFlame_timeout():
	can_flame = true


func _on_AnimationPlayer_animation_finished(anim_name):
	iframes = false
	healthbar.hide()


func _on_TimerSwipe_timeout():
	swipe_box.set_disabled(true)
	attacking = false
	$TimerSwipe2.start()


func _on_TimerSwipe2_timeout():
	can_swipe = true
