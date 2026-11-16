extends Area2D

var target: Node2D
var damage: float = 12.0
var speed: float = 420.0
var direction := Vector2.ZERO


func _ready() -> void:
	%Sprite.play(&"generate")


func _physics_process(delta: float) -> void:
	position += direction * speed * delta


func launch() -> void:
	direction = global_position.direction_to(target.global_position) if is_instance_valid(target) else Vector2.DOWN
	rotation = direction.angle()
	%Sprite.play(&"fly")
	set_deferred("monitoring", true)


func _on_sprite_animation_finished() -> void:
	if %Sprite.animation == &"generate":
		launch()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()


func _on_lifetime_timeout() -> void:
	queue_free()
