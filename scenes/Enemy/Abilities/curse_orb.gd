extends Area2D

@export var speed: float = 175.0
@export var turn_rate: float = 4.0

var target: Node2D
var damage: float = 25.0
var direction := Vector2.ZERO


func _physics_process(delta: float) -> void:
	if not is_instance_valid(target):
		return
	var wanted := global_position.direction_to(target.global_position)
	direction = wanted if direction == Vector2.ZERO else direction.lerp(wanted, clampf(turn_rate * delta, 0.0, 1.0)).normalized()
	position += direction * speed * delta
	%Glow.rotation += 6.0 * delta


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		ParticleFX.emit_at(self, &"blood", global_position)
		queue_free()


func _on_lifetime_timeout() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
