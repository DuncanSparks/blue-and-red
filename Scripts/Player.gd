extends KinematicBody2D

const orb_ref := preload("res://Prefabs/Orb.tscn")

export(float) var speed: float = 90.0

var motion := Vector2()

var health := 5
var stunned := false
var iframes := false

var shielding := false
var transforming := false
var pouncing := false

var stopped := false

var cooldown_shield := false

var demon_form := false
var demon_run_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var sprite_sword := $SpriteSword as AnimatedSprite
onready var healthbar := $Healthbar as TextureProgress


func _ready():
	pass # Replace with function body.
	

func _process(_delta):
	set_z_index(int(get_position().y))
	
	if not stopped and not stunned and not shielding and not transforming and not pouncing:
		if not demon_form:
			var input_x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			var input_y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			motion = Vector2(input_x, input_y)
		else:
			var mouse_pos := get_global_mouse_position()
			var unit_vector := get_position().direction_to(mouse_pos).normalized()
			demon_run_target = demon_run_target.linear_interpolate(mouse_pos + unit_vector * 60, 0.02)
			$Test.set_global_position(demon_run_target)
			motion = motion.linear_interpolate(Vector2.RIGHT.rotated(get_position().direction_to(demon_run_target).angle()), 0.05)
		
		sprite_management()
	elif not pouncing:
		motion = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack") and not stopped and not stunned and not shielding and not transforming and not pouncing:
		if not demon_form:
			sprite_sword.play("swing")
			$AreaSword/CollisionPolygon2D.set_disabled(false)
			
	if Input.is_action_just_pressed("attack_2") and not stopped and not stunned and not shielding and not transforming and not pouncing:
		if not demon_form:
			var orb := orb_ref.instance() as KinematicBody2D
			orb.set_position(get_position())
			orb.motion = Vector2.RIGHT.rotated(get_position().direction_to(get_global_mouse_position()).angle())
			get_tree().get_root().add_child(orb)
		else:
			pounce()
			
	if Input.is_action_just_pressed("action_shield") and not stopped and not cooldown_shield and not stunned and not transforming:
		shield()
			
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
	
	if Input.is_action_just_pressed("debug_1"):
		demon_form = not demon_form
	
	
func _physics_process(_delta):
	move_and_slide(motion * speed)
	
	
func shield():
	$SoundShield.play()
	sprite.play("shield_human")
	var spr := $Shield as Sprite
	spr.set_self_modulate(Color(1, 1, 1, 1))
	spr.set_scale(Vector2(1, 1))
	$Shield.show()
	$Shield/AnimationPlayer.play("Spin")
	shielding = true
	$Shield/Timer.start()
	cooldown_shield = true
	
	
func shield_end():
	shielding = false
	$TimerCooldownShield.start()
	
	
func pounce():
	$SoundPounce.play()
	$AnimationPlayerSpeed.stop()
	sprite.play("pounce_demon")
	speed = 250.0
	#motion = Vector2.RIGHT.rotated(get_global_position().direction_to(pounce_target).angle())
	pouncing = true
	$PounceBox/CollisionShape2D.set_disabled(false)
	$TimerPounce.start()
	
	
func hurt():
	$SoundHurt.play()
	sprite.play("ouch_demon" if demon_form else "ouch_human")
	health -= 1
	healthbar.set_value(health)
	healthbar.show()
	stunned = true
	$TimerStun.start()
	iframes = true
	$AnimationPlayer.play("Iframes")
	
	
func stop(value: bool):
	stopped = value
	if value:
		sprite.play("idle_demon" if demon_form else "idle_human")
	
	
func transformation(demon: bool):
	transforming = true
	sprite.play("ouch_demon" if demon_form else "ouch_human")
	$AnimationPlayerTransform.play("Transform Human to Demon" if demon else "Transform Demon to Human")


func sprite_management():
	if demon_form:
		sprite.play("run_demon" if is_moving() else "idle_demon")
	else:
		sprite.play("run_human" if is_moving() else "idle_human")
		
	if motion.x < 0:
		sprite.set_flip_h(true)
	elif motion.x > 0:
		sprite.set_flip_h(false)
		
		
func is_moving() -> bool:
	return motion != Vector2.ZERO


func _on_Hurtbox_body_entered(body):
	if not iframes:
		if not shielding:
			hurt()
		else:
			pass


func _on_TimerStun_timeout():
	stunned = false


func _on_AnimationPlayer_animation_finished(anim_name):
	iframes = false
	healthbar.hide()


func _on_AnimationPlayer2_animation_finished(anim_name):
	$Shield.hide()


func _on_TimerCooldownShield_timeout():
	cooldown_shield = false
	

func finish_transformation(use_override: bool = false, override: bool = false):
	demon_form = not demon_form if not use_override else override
	if demon_form:
		$AnimationPlayerSpeed.play("Speed Variance")
		$CollisionHuman.set_disabled(true)
		$CollisionDemon.set_disabled(false)
		$Healthbar.set_tint_progress(Color(1, 0, 0, 1))
	else:
		$AnimationPlayerSpeed.stop()
		speed = 90.0
		$CollisionDemon.set_disabled(true)
		$CollisionHuman.set_disabled(false)
		$Healthbar.set_tint_progress(Color("#00c6ff"))
	transforming = false


func _on_TimerPounce_timeout():
	$SoundLand.play()
	$PartsLand.set_emitting(false)
	$PartsLand.call_deferred("set_emitting", true)
	sprite.play("land_demon")
	motion = Vector2.ZERO
	$PounceBox/CollisionShape2D.set_disabled(true)
	$TimerPounce2.start()


func _on_TimerPounce2_timeout():
	pouncing = false
	speed = 90.0
	$AnimationPlayerSpeed.play("Speed Variance")
