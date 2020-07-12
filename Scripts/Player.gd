extends KinematicBody2D

const blast_ref := preload("res://Prefabs/Blast.tscn")

export(float) var speed: float = 90.0

export(AudioStream) var footstep_sound_human: AudioStream
export(AudioStream) var footstep_sound_demon: AudioStream

export(bool) var can_control := true

var motion := Vector2()

var health := 5
var stunned := false
var iframes := false

var can_shoot := true
var shooting := false
var shielding := false
var transforming := false
var pending_transformation := false
var pouncing := false

var stopped := false

var cooldown_shield := false

var demon_form := false
var demon_run_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var sprite_sword := $SpriteSword as AnimatedSprite
onready var healthbar := $Healthbar as TextureProgress

onready var timer_footsteps_human := $TimerFootstepsHuman as Timer
onready var timer_footsteps_demon := $TimerFootstepsDemon as Timer


func _ready():
	if not can_control:
		hide()
	

func _process(_delta):
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
		
	if not can_control:
		return
		
	set_z_index(int(get_position().y))
	
	if not stopped and not stunned and not shielding and not transforming and not pouncing and not shooting:
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
		
#	if is_moving():
#		if demon_form:
#			if timer_footsteps_demon.is_stopped():
#				timer_footsteps_demon.start()
#		else:
#			if timer_footsteps_human.is_stopped():
#				timer_footsteps_human.start()
#	else:
#		if demon_form:
#			timer_footsteps_demon.stop()
#		else:
#			timer_footsteps_human.stop()
	
	#if Input.is_action_just_pressed("attack") and not stopped and not stunned and not shielding and not transforming and not pouncing and not shooting:
	#	if not demon_form:
	#		sprite_sword.play("swing")
	#		$AreaSword/CollisionPolygon2D.set_disabled(false)
			
	if Input.is_action_just_pressed("attack") and not stopped and not stunned and not shielding and not transforming and not pouncing and not shooting:
		if not demon_form and can_shoot:
			$SoundBlast.play()
			var blast := blast_ref.instance() as KinematicBody2D
			blast.set_position(get_position())
			var angle := get_position().direction_to(get_global_mouse_position()).angle()
			blast.motion = Vector2.RIGHT.rotated(angle)
			blast.get_node("Sprite").set_rotation(angle)
			blast.get_node("CollisionShape2D").set_rotation(angle)
			get_node("..").add_child(blast)
			can_shoot = false
			$TimerCooldownShoot.start()
		#else:
		#	pounce()
			
	#if Input.is_action_just_pressed("action_shield") and not stopped and not cooldown_shield and not stunned and not transforming and not shooting:
	#	if not demon_form:
	#		shield()
	
	#if Input.is_action_just_pressed("debug_1"):
	#	demon_form = not demon_form
	
	
func _physics_process(_delta):
	if can_control:
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
	var tween := $TweenShieldMeter as Tween
	var meter := $CooldownShieldMeter as TextureProgress
	meter.show()
	tween.interpolate_property(meter, "value", 4.0, 0.0, 4.0)
	tween.start()
	$TimerCooldownShield.start()
	
	
func pounce():
	if not can_control:
		return
		
	if not stunned:
		$SoundPounce.play()
		$AnimationPlayerSpeed.stop()
		sprite.play("pounce_demon")
		speed = 320.0
		#motion = Vector2.RIGHT.rotated(get_global_position().direction_to(pounce_target).angle())
		pouncing = true
		$PounceBox/CollisionShape2D.set_disabled(false)
		$TimerPounce.start()
	else:
		$AnimationPlayerSpeed.play("Speed Variance")
		$TimerCooldownPounce.start()
		var tween := $TweenShieldMeter as Tween
		var meter := $CooldownPounceMeter as TextureProgress
		tween.interpolate_property(meter, "value", 3.0, 0.0, 3.0)
		tween.start()
		meter.show()
	
	
func heal(amount: int):
	$SoundHeal.play()
	health = min(health + amount, 5)
	healthbar.set_value(health)
	Controller.player_health = health
	healthbar.show()
	$TimerHeal.start()
	
	
func hurt(amount: int = 1):
	$SoundHurt.play()
	$SoundHurt2.play()
	sprite.play("ouch_demon" if demon_form else "ouch_human")
	health -= amount
	healthbar.set_value(health)
	Controller.player_health = health
	healthbar.show()
	stunned = true
	if health > 0:
		$TimerStun.start()
		iframes = true
		$AnimationPlayer.play("Iframes")
	else:
		Controller.goto_scene("res://Scenes/Gameover.tscn", get_global_position())
	
	
func stop(value: bool):
	stopped = value
	if value:
		sprite.play("idle_demon" if demon_form else "idle_human")
	
	
func transformation(demon: bool):
	if not pouncing:
		transforming = true
		sprite.play("ouch_demon" if demon_form else "ouch_human")
		$AnimationPlayerTransform.play("Transform Human to Demon" if demon else "Transform Demon to Human")
		Cursor.change_mode(demon)
	else:
		pending_transformation = true


func sprite_management():
	if demon_form:
		sprite.play("run_demon" if is_moving() else "idle_demon")
	else:
		sprite.play(("run_cast_human" if not can_shoot else "run_human") if is_moving() else ("idle_cast_human" if not can_shoot else "idle_human"))
		
	if motion.x < 0:
		sprite.set_flip_h(true)
	elif motion.x > 0:
		sprite.set_flip_h(false)
		
		
func is_moving() -> bool:
	return motion != Vector2.ZERO


func _on_Hurtbox_body_entered(body):
	if not iframes and not transforming and not pouncing:
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
	$CooldownShieldMeter.hide()
	
	
func start_pounce_meter(start: bool):
	if start:
		$TimerCooldownPounce.start()
		var tween := $TweenShieldMeter as Tween
		var meter := $CooldownPounceMeter as TextureProgress
		tween.interpolate_property(meter, "value", 3.0, 0.0, 3.0)
		tween.start()
		meter.show()
	else:
		
		$CooldownPounceMeter.hide()
		$TimerCooldownPounce.stop()
	

func finish_transformation(use_override: bool = false, override: bool = false):
	demon_form = not demon_form if not use_override else override
	if demon_form:
		$AnimationPlayerSpeed.play("Speed Variance")
		$CooldownShieldMeter.hide()
		$CollisionHuman.set_disabled(true)
		$CollisionDemon.set_disabled(false)
		$Healthbar.set_tint_progress(Color(1, 0, 0, 1))
		
		if not stopped:
			$TimerCooldownPounce.start()
			var tween := $TweenShieldMeter as Tween
			var meter := $CooldownPounceMeter as TextureProgress
			tween.interpolate_property(meter, "value", 3.0, 0.0, 3.0)
			tween.start()
			meter.show()
	else:
		$AnimationPlayerSpeed.stop()
		$CooldownPounceMeter.hide()
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
	$TimerCooldownPounce.start()
	var tween := $TweenShieldMeter as Tween
	var meter := $CooldownPounceMeter as TextureProgress
	tween.interpolate_property(meter, "value", 3.0, 0.0, 3.0)
	tween.start()
	meter.show()
	if pending_transformation:
		pending_transformation = false
		transformation(false)


func _on_TimerCooldownPounce_timeout():
	if not transforming:
		pounce()


func _on_TimerFootstepsHuman_timeout():
	Controller.play_sound_oneshot(footstep_sound_human, rand_range(0.95, 1.05), -24)


func _on_TimerFootstepsDemon_timeout():
	Controller.play_sound_oneshot(footstep_sound_demon, rand_range(0.95, 1.05), -24)


func _on_TimerDie_timeout():
	$SoundDie.play()


func _on_TimerHeal_timeout():
	healthbar.hide()


func _on_TimerCooldownShoot_timeout():
	can_shoot = true
