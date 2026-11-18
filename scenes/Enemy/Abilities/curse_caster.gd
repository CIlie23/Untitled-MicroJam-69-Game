extends Node2D

@export var orb_scene: PackedScene
@export var first_delay: float = 4.0
@export var damage: float = 25.0

var caster: CharacterBody2D


func setup(enemy: CharacterBody2D) -> void:
	caster = enemy


func _ready() -> void:
	await get_tree().create_timer(first_delay, false).timeout
	%CurseTimer.start()
	_on_curse_timer_timeout()


func _on_curse_timer_timeout() -> void:
	caster.play_cast()
	var orb = orb_scene.instantiate()
	orb.position = caster.position
	orb.target = caster.player_reference
	orb.damage = damage
	get_tree().current_scene.add_child(orb)
