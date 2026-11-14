extends CharacterBody2D


const SPEED = 300.0

# enemies re-assert themselves every physics tick; weapons read nearest_enemy
var nearest_enemy : Node2D
var nearest_enemy_distance : float = INF

var health : float = 100.0 :
	set(value):
		health = value
		%Health.value = value


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
