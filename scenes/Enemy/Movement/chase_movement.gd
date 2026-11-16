extends Node

@export var keep_distance: float = 0.0


func steer(enemy: CharacterBody2D, _delta: float) -> Vector2:
	if keep_distance > 0.0 and enemy.separation <= keep_distance:
		return Vector2.ZERO
	return enemy.global_position.direction_to(enemy.player_reference.global_position) * enemy.speed
