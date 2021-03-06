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
var pounce_disabled := false

var stopped := false

var cooldown_shield := false

var demon_form := false
var demon_run_target := Vector2()

onready var sprite := $Sprite as AnimatedSprite
onready var healthbar := $Healthbar as TextureProgress
onready var anim_player_footsteps := $AnimationPlayerFootsteps as AnimationPlayer


func _ready():
	if not can_control:
		hide()
		
	demon_run_target = get_global_mouse_position()
	

func _process(_delta):
	if Input.is_action_just_pressed("sys_fullscreen"):
		OS.set_window_fullscreen(not OS.is_window_fullscreen())
		
	if not can_control:
		return
		
	set_z_index(int(get_position().y))
	
	var mouse_pos := get_global_mouse_position()
	var unit_vector := get_position().direction_to(mouse_pos).normalized()
	demon_run_target = demon_run_target.linear_interpolate(mouse_pos + unit_vector * 40, 0.02)
	
	if not stopped and not stunned and not shielding and not transforming and not pouncing and not shooting:
		if not demon_form:
			var input_x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
			var input_y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
			motion = Vector2(input_x, input_y)
		else:
			motion = motion.linear_interpolate(Vector2.RIGHT.rotated(get_position().direction_to(demon_run_target).angle()), 0.05)
		
		sprite_management()
	elif not pouncing:
		motion = Vector2.ZERO

			
	if Input.is_action_just_pressed("attack") and not stopped and not stunned and not shielding and not transforming and not pouncing and not shooting:
		if not demon_form and can_shoot:
			$SoundBlast.play()
			var blast := blast_ref.instance() as KinematicBody2D
			blast.set_position(get_position())
			var angle := get_position().direction_to(get_global_mouse_position()).angle()
			blast.motion = Vector2.RIGHT.rotated(angle)
			blast.set_modulate(Color("#1e82e0"))
			blast.get_node("Sprite").set_rotation(angle)
			blast.get_node("CollisionShape2D").set_rotation(angle)
			blast.add_to_group("PlayerBlast")
			get_node("..").add_child(blast)
			can_shoot = false
			$TimerCooldownShoot.start()
			
	if is_moving() and not pouncing:
		anim_player_footsteps.play("Demon" if demon_form else "Human")
	else:
		anim_player_footsteps.stop()

	
func _physics_process(_delta):
	if can_control:
		move_and_slide(motion * speed)

	
func pounce():
	if not can_control:
		return
		
	if not stunned:
		$SoundPounce.play()
		$AnimationPlayerSpeed.stop()
		sprite.play("pounce_demon")
		speed = 320.0
		pouncing = true
		$PounceBox/CollisionShape2D.set_disabled(false)
		$TimerPounce.start()
	else:
		$AnimationPlayerSpeed.play("Speed Variance")
		$TimerCooldownPounce.start()
		var tween := $TweenShieldMeter as Tween
		var meter := $CooldownPounceMeter as TextureProgress
		tween.interpolate_property(meter, "value", 1.5, 0.0, 1.5)
		tween.start()
		meter.show()
	
	
func heal(amount: int):
	$SoundHeal.play()
	health = int(min(health + amount, 5))
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
	$TimerCooldownPounce.set_paused(true)
	$TweenShieldMeter.stop($CooldownPounceMeter)
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
		Controller.change_healthbar_color(demon)
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
	
	
func play_footstep_sound(base_pitch: float = 1.0):
	Controller.play_sound_oneshot(footstep_sound_demon if demon_form else footstep_sound_human, rand_range(base_pitch - 0.05, base_pitch + 0.05), -22 if demon_form else -24)


func _on_Hurtbox_body_entered(body):
	if not iframes and not transforming and not pouncing and not stopped:
		hurt()


func _on_TimerStun_timeout():
	stunned = false
	$TweenShieldMeter.resume($CooldownPounceMeter)
	$TimerCooldownPounce.set_paused(false)


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
		tween.interpolate_property(meter, "value", 1.5, 0.0, 1.5)
		tween.start()
		meter.show()
	else:
		$CooldownPounceMeter.hide()
		$TimerCooldownPounce.stop()
	

func disable_pounce(disable: bool):
	pounce_disabled = disable


func finish_transformation(use_override: bool = false, override: bool = false, use_iframes: bool = false):
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
			tween.interpolate_property(meter, "value", 1.5, 0.0, 1.5)
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
	if use_iframes and not stopped:
		iframes = true
		$AnimationPlayer.play("Iframes")


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
	if not pounce_disabled:
		$TimerCooldownPounce.start()
		var tween := $TweenShieldMeter as Tween
		var meter := $CooldownPounceMeter as TextureProgress
		tween.interpolate_property(meter, "value", 1.5, 0.0, 1.5)
		tween.start()
		meter.show()
		if pending_transformation:
			pending_transformation = false
			transformation(false)


func _on_TimerCooldownPounce_timeout():
	if not transforming:
		pounce()


func _on_TimerDie_timeout():
	$SoundDie.play()


func _on_TimerHeal_timeout():
	healthbar.hide()


func _on_TimerCooldownShoot_timeout():
	can_shoot = true
