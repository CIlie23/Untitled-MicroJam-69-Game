extends CharacterBody2D


const SPEED = 200.0

# cutscenes set this false while a timeline or a scripted beat runs
var can_move := true

func _physics_process(delta):
	if not can_move:
		velocity = Vector2.ZERO
		return

# setup direction of movement (diagonals allowed)
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
#normalize the directional movement
	direction = direction.normalized()
# setup the actual movement
	velocity = (direction * SPEED)
	move_and_slide()
