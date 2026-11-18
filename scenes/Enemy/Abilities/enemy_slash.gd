extends Area2D

@export var lifetime: float = 0.25

var damage: float = 20.0
var has_hit := false


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(%Arc, "modulate:a", 0.0, lifetime)
	tween.tween_callback(queue_free)


func _on_body_entered(body: Node2D) -> void:
	if not has_hit and body.has_method("take_damage"):
		has_hit = true
		body.take_damage(damage)
