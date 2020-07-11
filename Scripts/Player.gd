extends KinematicBody2D

const orb_ref := preload("res://Prefabs/Orb.tscn")

var speed := 90

var motion := Vector2()

var health := 5
var stunned := false
var iframes := false

var shielding := false
var transforming := false

var cooldown_shield := false

var demon_form := false

onready var sprite := $Sprite as AnimatedSprite
onready var sprite_sword := $SpriteSword as AnimatedSprite
onready var healthbar := $Healthbar as TextureProgress


func _ready():
	pass # Replace with function body.
	

func _process(_delta):
	set_z_index(get_position().y)
	
	if not stunned and not shielding and not transforming:
		var input_x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		var input_y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
		motion = Vector2(input_x, input_y)
		
		sprite_management()
	else:
		motion = Vector2.ZERO
	
	if Input.is_action_just_pressed("attack") and not stunned and not shielding and not transforming:
		if not demon_form:
			sprite_sword.play("swing")
			$AreaSword/CollisionPolygon2D.set_disabled(false)
			
	if Input.is_action_just_pressed("attack_2") and not stunned and not shielding and not transforming:
		if not demon_form:
			var orb := orb_ref.instance() as KinematicBody2D
			orb.set_position(get_position())
			orb.motion = Vector2.RIGHT.rotated(get_position().direction_to(get_global_mouse_position()).angle())
			get_tree().get_root().add_child(orb)
			
	if Input.is_action_just_pressed("action_shield") and not cooldown_shield and not stunned and not transforming:
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
	
	
func hurt():
	$SoundHurt.play()
	sprite.play("ouch_human")
	health -= 1
	healthbar.set_value(health)
	healthbar.show()
	stunned = true
	$TimerStun.start()
	iframes = true
	$AnimationPlayer.play("Iframes")
	
	
func transform(demon: bool):
	transforming = true
	sprite.play("ouch_human")
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
	

func finish_transformation():
	demon_form = true
	transforming = false
