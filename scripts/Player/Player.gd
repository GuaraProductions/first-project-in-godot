extends KinematicBody2D

const MAX_SPEED    = 80
const ACCELERATION = 500
const FRICTION     = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var speed = Vector2.ZERO 
var state = MOVE

onready var animation      = $Animations
onready var all_animations = $AnimationTree 
onready var animationState = all_animations.get("parameters/playback")

func _ready():
	all_animations.active = true

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			pass
			
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		all_animations.set("parameters/Idle/blend_position", input_vector)
		all_animations.set("parameters/Run/blend_position", input_vector)
		all_animations.set("parameters/Attack/blend_position", input_vector)
		animationState.travel("Run")
		speed = speed.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: 
		animationState.travel("Idle")
		speed = speed.move_toward(Vector2.ZERO, FRICTION * delta)
		
	speed = move_and_slide(speed)
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func attack_state(delta):
	speed = Vector2.ZERO
	animationState.travel("Attack")
	
func attack_end():
	state = MOVE
	
