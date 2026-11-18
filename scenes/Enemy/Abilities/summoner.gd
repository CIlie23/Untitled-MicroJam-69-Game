extends Node2D

signal summoned

@export var enemy_scene: PackedScene
@export var rotation_types: Array[Enemy] = []
@export var rare_type: Enemy
@export_range(0.0, 1.0) var rare_chance: float = 0.0
@export var count: int = 2
@export var spread: float = 40.0
@export_range(-1.0, 1.0) var minion_heal_chance: float = -1.0
@export var summon_on_spawn: bool = false
@export var spawn_summon_delay: float = 0.0
@export var minion_immunity: float = 0.0

var summoner: CharacterBody2D
var step := 0


func setup(enemy: CharacterBody2D) -> void:
	summoner = enemy


func _ready() -> void:
	if summon_on_spawn:
		summon_after_delay()


func summon_after_delay() -> void:
	%SummonTimer.stop()
	await get_tree().create_timer(spawn_summon_delay, false).timeout
	_on_summon_timer_timeout()
	%SummonTimer.start()


func _on_summon_timer_timeout() -> void:
	var type := next_type()
	summoner.play_attack()
	summoned.emit()
	for index in amount_for(type):
		summon(type)


func next_type() -> Enemy:
	if rare_type and randf() < rare_chance:
		return rare_type
	var type := rotation_types[step % rotation_types.size()]
	step += 1
	return type


func amount_for(type: Enemy) -> int:
	if type == rare_type:
		return 1
	if type.group_size.y > 1:
		return randi_range(type.group_size.x, type.group_size.y)
	return count


func summon(type: Enemy) -> void:
	var minion = enemy_scene.instantiate()
	minion.type = type
	minion.player_reference = summoner.player_reference
	if minion_heal_chance >= 0.0:
		minion.heal_drop_chance = minion_heal_chance
	if minion_immunity > 0.0:
		minion.make_immune(minion_immunity)
	minion.position = summoner.position + Vector2(randf_range(-spread, spread), randf_range(-spread, spread))
	get_tree().current_scene.add_child(minion)
