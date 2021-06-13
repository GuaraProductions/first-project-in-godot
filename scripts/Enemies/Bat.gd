extends KinematicBody2D

const EnemyDeathEffect = preload("res://scripts/Effects/EnemyDeathEffect.tscn")

export var ACCELERATION = 150
export var MAX_SPEED    = 50
export var FRICTION     = 200
export var WANDER_RANGE = 4

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity  = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE

onready var sprite        = $BatSprite
onready var stats         = $Stats
onready var playerSeeker  = $PlayerDetection
onready var hurtbox       = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderControl = $WanderController
onready var hitAnimation  = $HitEffectAnimation

func _ready(): state = pick_random_state([IDLE,WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		
		IDLE:
			
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wanderControl.get_time_left() == 0:
				update_wander()
		WANDER:
			
			seek_player()
			if wanderControl.get_time_left() == 0:
				update_wander()
				
			accelerate_towards_point(wanderControl.target_position, delta)
			
			if global_position.distance_to(wanderControl.target_position) <= WANDER_RANGE:
				update_wander()
			
		CHASE:
			
			var player = playerSeeker.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
			
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
		
	velocity = move_and_slide(velocity)
			
func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0
	
func seek_player():
	if playerSeeker.can_see_player():
		state = CHASE
		
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderControl.start_wander_timer(rand_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_Hurtbox_invincibility_ended():
	hitAnimation.play("Stop")
	
func _on_Hurtbox_invincibility_started():
	hitAnimation.play("Play")
