extends Node2D

@export var sword_scene: PackedScene
@export var attack_range: float = 650.0
@export var damage: float = 12.0
@export var speed: float = 420.0
@export var patterns: Array[StringName] = [&"aimed", &"omni", &"fan"]

@export_group("Aimed")
@export var count: int = 3
@export var spacing: float = 56.0
@export var lift: float = 60.0

@export_group("Omni")
@export var omni_count: int = 12
@export var omni_radius: float = 70.0

@export_group("Fan")
@export var fan_count: int = 7
@export var fan_spread_degrees: float = 70.0

var thrower: CharacterBody2D
var volleys := 0


func setup(enemy: CharacterBody2D) -> void:
	thrower = enemy


func _on_throw_timer_timeout() -> void:
	if thrower.separation <= attack_range:
		throw_volley()


func throw_volley() -> void:
	thrower.play_cast()
	var pattern := patterns[volleys % patterns.size()]
	volleys += 1
	match pattern:
		&"omni":
			throw_omni()
		&"fan":
			throw_fan()
		_:
			throw_aimed()


func throw_aimed() -> void:
	for index in count:
		conjure(Vector2((index - (count - 1) / 2.0) * spacing, -lift))


func throw_omni() -> void:
	for index in omni_count:
		var outward := Vector2.RIGHT.rotated(TAU * index / omni_count)
		conjure(outward * omni_radius, outward)


func throw_fan() -> void:
	var aim := thrower.global_position.direction_to(thrower.player_reference.global_position)
	var spread := deg_to_rad(fan_spread_degrees)
	for index in fan_count:
		var angle := -spread * 0.5 + spread * index / maxf(fan_count - 1, 1)
		conjure(Vector2(0, -lift), aim.rotated(angle))


func conjure(offset: Vector2, fixed_direction := Vector2.ZERO) -> void:
	var sword = sword_scene.instantiate()
	sword.position = thrower.position + offset
	sword.target = thrower.player_reference
	sword.fixed_direction = fixed_direction
	sword.damage = damage
	sword.speed = speed
	get_tree().current_scene.add_child(sword)
