extends WeaponNode

@export var aura_color: Color = Color(0.85, 1.0, 0.6, 0.18)
@export var knockback: float = 40.0

@onready var aura: Area2D = %Aura
@onready var shape: CircleShape2D = %AuraShape.shape


func apply_level() -> void:
	shape.radius = current_area()
	queue_redraw()


func attack() -> void:
	var bodies := aura.get_overlapping_bodies()
	for body in bodies:
		hit(body, global_position.direction_to(body.global_position) * knockback)
	if not bodies.is_empty():
		attacked.emit()


func _draw() -> void:
	draw_circle(Vector2.ZERO, shape.radius, aura_color)
