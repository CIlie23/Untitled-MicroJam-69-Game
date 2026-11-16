extends Node

@export var aim_spread_degrees: float = 25.0
@export var wobble: float = 0.35
@export var wobble_speed: float = 6.0

var direction := Vector2.ZERO
var time := 0.0


func steer(enemy: CharacterBody2D, delta: float) -> Vector2:
	if direction == Vector2.ZERO:
		direction = aim_past(enemy)
	time += delta
	var sway := direction.orthogonal() * sin(time * wobble_speed) * wobble
	return (direction + sway).normalized() * enemy.speed


func aim_past(enemy: CharacterBody2D) -> Vector2:
	var spread := deg_to_rad(randf_range(-aim_spread_degrees, aim_spread_degrees))
	return enemy.global_position.direction_to(enemy.player_reference.global_position).rotated(spread)
