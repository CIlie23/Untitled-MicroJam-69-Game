extends Node2D
 
@export var player : CharacterBody2D
@export var enemy : PackedScene
 
@export var enemy_types : Array[Enemy]
 
var distance : float = 400
var can_spawn : bool = true
 
# shortcut: no difficulty ramp yet, type is random per spawn; index by elapsed
# minutes once the run timer exists.
 
func _physics_process(_delta):
	if get_tree().get_node_count_in_group("Enemy") < 700:
		can_spawn = true
	else:
		can_spawn = false
 
func spawn(pos : Vector2, elite : bool = false):
	if not can_spawn and not elite:
		return
 
	var enemy_instance = enemy.instantiate()
	if enemy_types.size() > 0:
		enemy_instance.type = enemy_types.pick_random()
	#enemy_instance.position = get_random_position()
	
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	get_tree().current_scene.add_child(enemy_instance)
 
 
func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
 
 
func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())
 
func _on_pattern_timeout():
	# spawn enemies in circle
	for i in range(75):
		spawn(get_random_position())
 
func _on_elite_timeout():
	spawn(get_random_position(), true)

func _on_normal_timeout() -> void:
	spawn(get_random_position())
