extends Node2D

@export var sword_scene: PackedScene
@export var attack_range: float = 650.0
@export var count: int = 3
@export var spacing: float = 56.0
@export var lift: float = 60.0
@export var damage: float = 12.0
@export var speed: float = 420.0

var thrower: CharacterBody2D


func setup(enemy: CharacterBody2D) -> void:
	thrower = enemy


func _on_throw_timer_timeout() -> void:
	if thrower.separation <= attack_range:
		throw_volley()


func throw_volley() -> void:
	thrower.play_attack()
	for index in count:
		conjure(Vector2((index - (count - 1) / 2.0) * spacing, -lift))


func conjure(offset: Vector2) -> void:
	var sword = sword_scene.instantiate()
	sword.position = thrower.position + offset
	sword.target = thrower.player_reference
	sword.damage = damage
	sword.speed = speed
	get_tree().current_scene.add_child(sword)
