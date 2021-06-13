extends KinematicBody2D

const PlayerHurtSound = preload("res://scripts/Misc/PlayerHurtSound.tscn")

export var MAX_SPEED    = 80
export var ACCELERATION = 500
export var FRICTION     = 500
export var ROLL_SPEED   = 125

enum {
	MOVE,
	ROLL,
	ATTACK
}

var speed_vector = Vector2.ZERO 
var roll_vector  = Vector2.DOWN
var state = MOVE
var stats = PlayerStats

onready var animation            = $Animations
onready var all_animations       = $AnimationTree 
onready var animationState       = all_animations.get("parameters/playback")
onready var swordHitbox          = $HitboxPivot/Sword
onready var hurtbox              = $Hurtbox
onready var blinkAnimationPlayer = $HitEffectAnimation

func _ready():
	randomize()
	stats.connect("no_health",self,"queue_free")
	all_animations.active = true
	swordHitbox.knockback_vector = roll_vector

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		
		ROLL:
			roll_state(delta)
			
		ATTACK:
			attack_state(delta)
	
func move_state(delta):
	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		
		all_animations.set("parameters/Idle/blend_position", input_vector)
		all_animations.set("parameters/Run/blend_position", input_vector)
		all_animations.set("parameters/Attack/blend_position", input_vector)
		all_animations.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		speed_vector = speed_vector.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
	else: 
		animationState.travel("Idle")
		speed_vector = speed_vector.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
func roll_state(_delta):
	speed_vector = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()
		
func attack_state(_delta):
	#print('atacando')
	speed_vector = Vector2.ZERO
	animationState.travel("Attack")
	
func roll_animation_finished():
	speed_vector *= 0.8
	state = MOVE
	
func attack_end():
	state = MOVE
	
func move():
	speed_vector = move_and_slide(speed_vector)
	
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
	var playerHurtSounds = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSounds)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
