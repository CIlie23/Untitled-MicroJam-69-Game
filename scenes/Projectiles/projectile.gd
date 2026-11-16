extends Area2D

var direction : Vector2 = Vector2.RIGHT
var speed : float = 200
var damage : float = 1
var stats : PlayerStats
@export var spin_speed : float = 14.0

func _physics_process(delta):
	position += direction * speed * delta
	%Sprite2D.rotation += spin_speed * delta


func _on_body_entered(body):
	if body.has_method("take_damage"):
		stats.deal_damage(body, damage)
		body.knockback = direction * 90


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
