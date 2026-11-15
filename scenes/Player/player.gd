extends CharacterBody2D


const SPEED = 300.0

# enemies re-assert themselves every physics tick; weapons read nearest_enemy
var nearest_enemy : Node2D
var nearest_enemy_distance : float = INF

var level : int = 1:
	set(value):
		level = value
		_update_hud()
		%PickCard.show_options()


var dead : bool = false
# the other soul is driving: no input, but weapons keep firing on their own
var possessed : bool = false

var health : float = 100.0 :
	set(value):
		health = value
		%Health.value = value
		# out of health is not the end: your soul is spent, so the other one takes
		# the body and you get one typing attempt to win it back
		if health <= 0 and not possessed and not dead:
			%VersusBar.player_downed()

var XP : int = 0:
	set(value):
		XP = value
		_update_hud()
var total_XP : int = 0
# gems the body picked up this run, whoever was driving
var souls : int = 0


func _ready() -> void:
	_update_hud()


# +5 per level, never capped; 10, 15, 20, 25 ...
func _xp_needed() -> int:
	return 10 + (level - 1) * 5


func _update_hud() -> void:
	%XP.max_value = _xp_needed()
	%XP.value = XP
	%Level.text = "LVL %d" % level


func _physics_process(delta):
# enemies added to the world after the player, so this reset lands before they compare
	nearest_enemy_distance = INF
	if possessed:
		velocity = Vector2.ZERO
		return
# setup direction of movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
# stop diagonal movement by listening for input then setting axis to zero
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
		direction.y = 0
	elif Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down"):
		direction.x = 0
	else:
		direction = Vector2.ZERO
	
#normalize the directional movement
	direction = direction.normalized()
# setup the actual movement
	velocity = (direction * SPEED)
	move_and_slide()

func take_damage(amount):
	health -= amount
	%VersusBar.player_hurt(amount) # damage is what lets the soul catch up


# the real loss: failed the typing attempt, or the soul built a full-bar lead
func die() -> void:
	if dead:
		return
	dead = true
	possessed = false
	health = 0
	%TypingChallenge.stop() # silent: the caller is not listening any more
	%DeathScreen.show_death()

func _on_area_2d_body_entered(body: Node2D) -> void:
	# reduce player health based on enemy health
	take_damage(body.damage) 


func _on_timer_timeout() -> void:
	pass # Replace with function body.

func check_XP():
	# while, not if: one big gain can clear several levels
	while XP >= _xp_needed():
		XP -= _xp_needed()
		level += 1


func gain_XP(amount):
	souls += 1
	%Souls.text = str(souls)
	# shared body: kills feed both souls, the player keeps the larger share.
	# Possessed, the soul farms alone and the player stops levelling.
	if possessed:
		%VersusBar.soul_earned(amount)
		return
	XP += amount
	total_XP += amount
	%VersusBar.player_earned(amount)
	check_XP()


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(owner)
