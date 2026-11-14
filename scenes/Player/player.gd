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


var health : float = 100.0 :
	set(value):
		health = value
		%Health.value = value

var XP : int = 0:
	set(value):
		XP = value
		_update_hud()
var total_XP : int = 0


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
	XP += amount
	total_XP += amount
	check_XP()


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(owner)
