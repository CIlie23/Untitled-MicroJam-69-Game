extends Node

@export var flee_distance: float = 220.0
@export var keep_distance: float = 380.0
@export var flee_speed_scale: float = 1.3


func steer(enemy: CharacterBody2D, _delta: float) -> Vector2:
	var toward := enemy.global_position.direction_to(enemy.player_reference.global_position)
	if enemy.separation < flee_distance:
		return -toward * enemy.speed * flee_speed_scale
	if enemy.separation > keep_distance:
		return toward * enemy.speed
	return Vector2.ZERO
