extends Node2D

@export var warning_time: float = 0.7
@export var radius: float = 34.0
@export var color: Color = Color(1, 0.15, 0.15, 0.8)

var blast_scene: PackedScene
var damage: float = 9.0
var fill := 0.0


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "fill", 1.0, warning_time)
	tween.tween_callback(explode)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, color, 2.0)
	draw_circle(Vector2.ZERO, radius * fill, Color(color, 0.25))


func explode() -> void:
	var explosion = blast_scene.instantiate()
	explosion.position = position
	explosion.damage = damage
	get_parent().add_child(explosion)
	queue_free()
