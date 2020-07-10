extends KinematicBody2D

const orb_ref := preload("res://Prefabs/Orb.tscn")

var speed := 90

var motion := Vector2()

var demon_form := false

onready var sprite := $Sprite as AnimatedSprite
onready var sprite_sword := $SpriteSword as AnimatedSprite


func _ready():
	pass # Replace with function body.
	

func _process(_delta):
	set_z_index(get_position().y)
	
	var input_x := int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var input_y := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	motion = Vector2(input_x, input_y)
	
	sprite_management()
	
	if Input.is_action_just_pressed("attack"):
		if not demon_form:
			sprite_sword.play("swing")
			$AreaSword/CollisionPolygon2D.set_disabled(false)
			
	if Input.is_action_just_pressed("attack_2"):
		if not demon_form:
			var orb := orb_ref.instance()
			orb.set_position(get_position())
			orb.motion = Vector2.RIGHT.rotated(get_position().direction_to(get_global_mouse_position()).angle())
			get_tree().get_root().add_child(orb)
	
	if Input.is_action_just_pressed("debug_1"):
		demon_form = not demon_form
	
	
func _physics_process(_delta):
	motion = move_and_slide(motion * speed)


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
