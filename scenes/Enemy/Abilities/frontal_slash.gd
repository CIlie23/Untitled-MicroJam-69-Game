extends Node2D

@export var slash_scene: PackedScene
@export var reach: float = 150.0
@export var windup: float = 0.35
@export var damage: float = 20.0
@export var arc_scale: float = 1.0

var attacker: CharacterBody2D


func setup(enemy: CharacterBody2D) -> void:
	attacker = enemy


func _on_slash_timer_timeout() -> void:
	if attacker.separation <= reach:
		strike()


func strike() -> void:
	attacker.play_attack()
	var direction := attacker.global_position.direction_to(attacker.player_reference.global_position)
	await get_tree().create_timer(windup, false).timeout
	var slash = slash_scene.instantiate()
	slash.position = attacker.position
	slash.rotation = direction.angle()
	slash.scale = Vector2.ONE * arc_scale
	slash.damage = damage
	get_tree().current_scene.add_child(slash)
