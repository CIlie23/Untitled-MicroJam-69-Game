extends Node2D

signal casting

@export var blast_scene: PackedScene
@export var warning_scene: PackedScene
@export var first_delay: float = 10.5
@export var attack_range: float = 750.0
@export var damage: float = 9.0
@export var windup: float = 0.5

@export_group("Asterisk")
@export var arms: int = 8
@export var steps: int = 7
@export var step_distance: float = 60.0
@export var step_time: float = 0.08

@export_group("Scatter")
@export var scatter_count: int = 14
@export var scatter_radius: float = 450.0
@export var scatter_stagger: float = 0.05

var caster: CharacterBody2D
var casts := 0


func setup(enemy: CharacterBody2D) -> void:
	caster = enemy


func _ready() -> void:
	await get_tree().create_timer(first_delay, false).timeout
	%CastTimer.start()
	_on_cast_timer_timeout()


func _on_cast_timer_timeout() -> void:
	if caster.separation <= attack_range:
		cast()


func cast() -> void:
	caster.play_attack()
	casting.emit()
	casts += 1
	if casts % 2 == 1:
		cast_asterisk()
	else:
		cast_scatter()


func cast_asterisk() -> void:
	var origin := caster.position
	var spin := randf() * TAU
	await get_tree().create_timer(windup, false).timeout
	for step in range(1, steps + 1):
		for arm in arms:
			blast(origin + Vector2.RIGHT.rotated(spin + TAU * arm / arms) * step * step_distance)
		await get_tree().create_timer(step_time, false).timeout


func cast_scatter() -> void:
	var center: Vector2 = caster.player_reference.position
	for index in scatter_count:
		warn(center + Vector2.RIGHT.rotated(randf() * TAU) * sqrt(randf()) * scatter_radius)
		await get_tree().create_timer(scatter_stagger, false).timeout


func blast(pos: Vector2) -> void:
	var explosion = blast_scene.instantiate()
	explosion.position = pos
	explosion.damage = damage
	get_tree().current_scene.add_child(explosion)


func warn(pos: Vector2) -> void:
	var warning = warning_scene.instantiate()
	warning.position = pos
	warning.blast_scene = blast_scene
	warning.damage = damage
	get_tree().current_scene.add_child(warning)
