extends Node2D

@export var blast_scene: PackedScene
@export var tint: Color = Color(0.55, 1, 0.4, 1)
@export var attack_range: float = 520.0
@export var steps: int = 9
@export var step_distance: float = 55.0
@export var step_time: float = 0.06
@export var windup: float = 0.45
@export var damage: float = 12.0

var caster: CharacterBody2D


func setup(enemy: CharacterBody2D) -> void:
	caster = enemy


func _on_venom_timer_timeout() -> void:
	if caster.separation <= attack_range:
		spit()


func spit() -> void:
	caster.play_cast()
	var origin := caster.position
	var direction := caster.global_position.direction_to(caster.player_reference.global_position)
	await get_tree().create_timer(windup, false).timeout
	for step in range(1, steps + 1):
		var blast = blast_scene.instantiate()
		blast.position = origin + direction * step * step_distance
		blast.damage = damage
		blast.modulate = tint
		get_tree().current_scene.add_child(blast)
		await get_tree().create_timer(step_time, false).timeout
