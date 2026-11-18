extends Node2D

const DEATH_FX := preload("res://scenes/Enemy/DeathFx/death_fx.tscn")

@export var enemy_scene: PackedScene
@export var clone_type: Enemy
@export var clone_count: int = 2
@export var first_delay: float = 12.0
@export var min_teleport_distance: float = 350.0
@export var view_margin: float = 120.0

var caster: CharacterBody2D


func setup(enemy: CharacterBody2D) -> void:
	caster = enemy


func _ready() -> void:
	await get_tree().create_timer(first_delay, false).timeout
	%CloneTimer.start()
	_on_clone_timer_timeout()


func _on_clone_timer_timeout() -> void:
	caster.play_cast()
	for index in clone_count:
		spawn_clone(caster.position + Vector2.RIGHT.rotated(TAU * index / clone_count) * 70.0)
	teleport()


func spawn_clone(pos: Vector2) -> void:
	var clone = enemy_scene.instantiate()
	clone.type = clone_type
	clone.player_reference = caster.player_reference
	clone.position = pos
	clone.make_immune(0.5)
	get_tree().current_scene.add_child(clone)


func teleport() -> void:
	puff(caster.position)
	caster.position = random_spot_in_view()
	puff(caster.position)


func random_spot_in_view() -> Vector2:
	var camera := get_viewport().get_camera_2d()
	var center: Vector2 = camera.get_screen_center_position() if camera else caster.player_reference.position
	var half := get_viewport().get_visible_rect().size * 0.5 - Vector2.ONE * view_margin
	var player_pos: Vector2 = caster.player_reference.position
	var spot := center
	for attempt in 20:
		spot = center + Vector2(randf_range(-half.x, half.x), randf_range(-half.y, half.y))
		if spot.distance_to(player_pos) >= min_teleport_distance:
			return spot
	return spot


func puff(pos: Vector2) -> void:
	var fx = DEATH_FX.instantiate()
	fx.position = pos
	fx.scale = Vector2.ONE * 2.0
	get_tree().current_scene.add_child(fx)
