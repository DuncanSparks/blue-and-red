extends KinematicBody2D

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

var can_flame := false
var can_pounce := false
var pounce_target := Vector2()

var nav_path: PoolVector2Array = []
var nav_node: Navigation2D = null
var player_ref: KinematicBody2D = null

onready var sprite := $Sprite as AnimatedSprite
onready var sound_hurt := $SoundHurt as AudioStreamPlayer
onready var healthbar := $Healthbar as TextureProgress

func _ready():
	nav_node = get_node("../Navigation2D")
	player_ref = get_node("../Player")
	if path_to_player:
		nav_path = nav_node.get_simple_path(get_global_position(), player_ref.get_global_position(), false)
		$TimerNav.start()
		
	$TimerStartPounce.set_wait_time(rand_range(2.5, 4))
	$TimerStartFlame.set_wait_time(rand_range(3.5, 6))
	$TimerStartPounce.start()
	$TimerStartFlame.start()
	
		
func _process(delta):
	set_z_index(int(get_position().y))
	
	if not stunned and not attacking:
		if path_to_player:
			move_along_path(speed * delta)
		
		sprite_management()
	
	var distance_to_player := get_global_position().distance_to(player_ref.get_global_position())
	
	if not attacking and can_flame:
		flame()
	
	if distance_to_player <= 60 and not attacking and can_pounce:
		pounce()
		
		
func _physics_process(delta):
	move_and_slide(motion * speed)
	
	
func swipe():
	attacking = true
	motion = Vector2.ZERO
	
	
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
	
	
func hurt():
	sound_hurt.play()
	sprite.play("ouch")
	health -= 1
	healthbar.set_value(health)
	healthbar.show()
	stunned = true
	motion = Vector2.ZERO
	if health <= 0:
		$ParticlesDeath.set_emitting(true)
		$CollisionShape2D.call_deferred("set_disabled", false)
		var tween := $TweenFade as Tween
		tween.interpolate_property(sprite, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.42)
		tween.start()
		$TimerDeath.start()
	else:
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
	elif motion.x > 0:
		sprite.set_flip_h(false)
		
		
func is_moving() -> bool:
	return motion != Vector2.ZERO


func _on_TimerNav_timeout():
	nav_path = nav_node.get_simple_path(get_global_position(), player_ref.get_global_position(), false)


func _on_Hurtbox_body_entered(body):
	hurt()


func _on_Hurtbox_area_entered(area):
	hurt()
	
	
func _on_TimerStartPounce_timeout():
	can_pounce = true


func _on_TimerStun_timeout():
	stunned = false


func _on_TimerAttack_timeout():
	attacking = false


func _on_TimerPounce_timeout():
	speed = 200
	motion = Vector2.RIGHT.rotated(get_global_position().direction_to(pounce_target).angle())
	$SoundPounce.play()
	pouncing = true
	$PounceBox/CollisionShape2D.set_disabled(false)
	$TimerPounce2.start()


func _on_TimerPounce2_timeout():
	$SoundLand.play()
	sprite.play("land")
	$PartsLand.set_emitting(true)
	motion = Vector2.ZERO
	pouncing = false
	speed = 70
	$PounceBox/CollisionShape2D.set_disabled(true)
	$TimerPounce3.start()
	$TimerStartPounce.set_wait_time(rand_range(2.5, 4))
	$TimerStartPounce.start()


func _on_TimerFlame_timeout():
	$SoundFlame.play()
	sprite.play("flame_2")
	var flame_inst := flame_ref.instance() as KinematicBody2D
	flame_inst.set_position(get_global_position())
	flame_inst.motion = Vector2.RIGHT.rotated(get_position().direction_to(player_ref.get_global_position()).angle())
	flame_inst.get_node("AnimatedSprite").play("idle_flame")
	flame_inst.set_scale(Vector2(1.5, 1.5))
	flame_inst.set_collision_layer_bit(15, true)
	flame_inst.set_collision_mask_bit(15, true)
	flame_inst.set_collision_layer_bit(5, false)
	flame_inst.set_collision_mask_bit(5, false)
	flame_inst.grow()
	flame_inst.speed = 200
	get_tree().get_root().add_child(flame_inst)
	$TimerFlame2.start()
	$TimerStartFlame.set_wait_time(rand_range(3.5, 6))
	$TimerStartFlame.start()


func _on_TimerStartFlame_timeout():
	can_flame = true


func _on_AnimationPlayer_animation_finished(anim_name):
	iframes = false
	healthbar.hide()
