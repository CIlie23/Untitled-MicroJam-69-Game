extends Node2D

@export var player : CharacterBody2D
@export var enemy : PackedScene

@export var enemy_types : Array[Enemy]
signal final_boss_spawned(boss: Node2D)
signal final_boss_died

@export var unique_bosses : Array[Enemy] = []
@export var final_boss : Enemy
@export var final_boss_at_start : bool = false
@export var test_spawns_at_start : Array[Enemy] = []
@export var boss_spawn_distance : float = 500
@export var reference_run_length : float = 1800.0

@export var distance : float = 800
@export var pattern_count : int = 25
@export var group_spread : float = 50.0
var can_spawn : bool = true
var elapsed : float = 0.0
var rng := RandomNumberGenerator.new()
var unique_index : int = 0
var pace : float = 1.0

func _ready() -> void:
	if final_boss_at_start:
		spawn_final_boss.call_deferred()
	spawn_test_enemies.call_deferred()


func spawn_final_boss() -> void:
	spawn_final_boss_at(player.position + Vector2.RIGHT.rotated(randf() * TAU) * boss_spawn_distance)


func spawn_final_boss_at(pos : Vector2) -> Node2D:
	end_regular_spawns()
	var boss := spawn_one(pos, false, final_boss)
	boss.died.connect(_on_final_boss_died)
	final_boss_spawned.emit(boss)
	return boss


func _on_final_boss_died() -> void:
	final_boss_died.emit()


func end_regular_spawns() -> void:
	for timer in [%Normal, %Pattern, %Elite, %Unique]:
		timer.stop()


func spawn_test_enemies() -> void:
	for index in test_spawns_at_start.size():
		var angle := TAU * index / test_spawns_at_start.size()
		spawn(player.position + Vector2.RIGHT.rotated(angle) * boss_spawn_distance * 0.8, false, test_spawns_at_start[index])


func set_run_length(length : float) -> void:
	pace = reference_run_length / length
	for timer in [%Elite, %Unique]:
		timer.wait_time /= pace
		if not timer.is_stopped():
			timer.start()


func _process(delta: float) -> void:
	elapsed += delta * pace


func _physics_process(_delta):
	if get_tree().get_node_count_in_group("Enemy") < 700:
		can_spawn = true
	else:
		can_spawn = false

func spawn(pos : Vector2, elite : bool = false, type : Enemy = null):
	if not can_spawn and not elite:
		return
	var chosen := type if type else pick_type()
	var members := rng.randi_range(chosen.group_size.x, chosen.group_size.y)
	for index in members:
		var offset := Vector2.ZERO if index == 0 else Vector2(randf_range(-group_spread, group_spread), randf_range(-group_spread, group_spread))
		spawn_one(pos + offset, elite, chosen)


func spawn_one(pos : Vector2, elite : bool, type : Enemy) -> Node2D:
	var enemy_instance = enemy.instantiate()
	enemy_instance.type = type
	enemy_instance.position = pos
	enemy_instance.player_reference = player
	enemy_instance.elite = elite
	get_tree().current_scene.add_child(enemy_instance)
	return enemy_instance


func unlocked_types() -> Array[Enemy]:
	var result : Array[Enemy] = []
	for enemy_type in enemy_types:
		if enemy_type.unlock_time <= elapsed and enemy_type.spawn_weight > 0.0:
			result.append(enemy_type)
	return result


func pick_type() -> Enemy:
	var available := unlocked_types()
	var weights := PackedFloat32Array()
	for enemy_type in available:
		weights.append(enemy_type.spawn_weight)
	return available[rng.rand_weighted(weights)]


func get_random_position() -> Vector2:
	return player.position + distance * Vector2.RIGHT.rotated(randf_range(0, 2 * PI))


func amount(number : int = 1):
	for i in range(number):
		spawn(get_random_position())

func _on_pattern_timeout():
	# spawn enemies in circle
	for i in range(pattern_count):
		spawn(get_random_position())

func _on_elite_timeout():
	spawn(get_random_position(), true)

func _on_normal_timeout() -> void:
	spawn(get_random_position())


func _on_unique_timeout() -> void:
	if unique_bosses.is_empty():
		return
	spawn(get_random_position(), false, unique_bosses[unique_index % unique_bosses.size()])
	unique_index += 1
