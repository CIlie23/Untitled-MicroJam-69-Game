extends Node

@export var orbit_distance: float = 110.0
@export var distance_correction: float = 2.0
@export var clockwise: bool = true
@export var flip_cooldown: float = 0.6
@export var gem_hunt_range: float = 450.0
@export var retarget_interval: float = 0.25

var since_flip := 0.0
var since_retarget := 0.0
var gem_target: Node2D


func _process(delta: float) -> void:
	since_flip += delta
	since_retarget += delta


func bump() -> void:
	if since_flip >= flip_cooldown:
		clockwise = not clockwise
		since_flip = 0.0


func steer(body: Node2D, target: Node2D) -> Vector2:
	var gem := hunted_gem(body)
	if gem:
		return body.global_position.direction_to(gem.global_position)
	return orbit(body, target)


func hunted_gem(body: Node2D) -> Node2D:
	if since_retarget >= retarget_interval:
		since_retarget = 0.0
		gem_target = nearest_gem(body)
	return gem_target if is_instance_valid(gem_target) else null


func nearest_gem(body: Node2D) -> Node2D:
	var best: Node2D = null
	var best_distance := gem_hunt_range
	for pickup in body.get_tree().get_nodes_in_group(&"pickups"):
		var distance := body.global_position.distance_to(pickup.global_position)
		if pickup.type is Gem and distance < best_distance:
			best = pickup
			best_distance = distance
	return best


func orbit(body: Node2D, target: Node2D) -> Vector2:
	if target == null:
		return Vector2.ZERO
	var away := target.global_position.direction_to(body.global_position)
	var distance := target.global_position.distance_to(body.global_position)
	var tangent := away.orthogonal() * (1.0 if clockwise else -1.0)
	var push := clampf((orbit_distance - distance) / orbit_distance * distance_correction, -1.0, 1.0)
	return (tangent + away * push).normalized()
