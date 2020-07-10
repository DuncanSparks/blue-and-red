extends KinematicBody2D

export(bool) var path_to_player := true

var motion := Vector2()
var speed := 70

var health := 3
var stunned := false

var nav_path: PoolVector2Array = []
var nav_node: Navigation2D = null
var player_ref: KinematicBody2D = null

onready var sprite := $Sprite as AnimatedSprite
onready var sound_hurt := $SoundHurt as AudioStreamPlayer

func _ready():
	nav_node = get_node("../Navigation2D")
	player_ref = get_node("../Player")
	if path_to_player:
		nav_path = nav_node.get_simple_path(get_global_position(), player_ref.get_global_position(), false)
		$TimerNav.start()
		
		
func _process(delta):
	set_z_index(get_position().y)
	
	if not stunned:
		if path_to_player:
			move_along_path(speed * delta)
		
		sprite_management()
		
		
func _physics_process(delta):
	move_and_slide(motion * speed)
	
	
func hurt():
	sound_hurt.play()
	sprite.play("ouch")
	health -= 1
	stunned = true
	motion = Vector2.ZERO
	if health <= 0:
		$ParticlesDeath.set_emitting(true)
		$CollisionShape2D.set_disabled(true)
		var tween := $TweenFade as Tween
		tween.interpolate_property(sprite, "self_modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.42)
		tween.start()
		$TimerDeath.start()
	else:
		$TimerStun.start()


func move_along_path(distance: float):
	var start_point := get_global_position()
	for i in range(nav_path.size()):
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


func _on_TimerStun_timeout():
	stunned = false
