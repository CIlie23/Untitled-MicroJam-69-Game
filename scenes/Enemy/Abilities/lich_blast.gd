extends Area2D

var damage: float = 15.0
var has_hit := false


func _ready() -> void:
	%Burst.play()


func _on_body_entered(body: Node2D) -> void:
	if not has_hit and body.has_method("take_damage"):
		has_hit = true
		body.take_damage(damage)


func _on_burst_animation_finished() -> void:
	queue_free()
