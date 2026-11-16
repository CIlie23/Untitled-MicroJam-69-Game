extends Node

@export var windup_time: float = 0.8
@export var charge_time: float = 1.4

var charging := true
var charge_direction := Vector2.ZERO
var phase_left := 0.0


func steer(enemy: CharacterBody2D, delta: float) -> Vector2:
	phase_left -= delta
	if phase_left <= 0.0:
		next_phase(enemy)
	return charge_direction * enemy.speed if charging else Vector2.ZERO


func next_phase(enemy: CharacterBody2D) -> void:
	charging = not charging
	if charging:
		charge_direction = enemy.global_position.direction_to(enemy.player_reference.global_position)
		phase_left = charge_time
	else:
		phase_left = windup_time
