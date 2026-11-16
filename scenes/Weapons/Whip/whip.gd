extends WeaponNode

@export var knockback: float = 120.0

@onready var pivot: Node2D = %Pivot
@onready var hitbox: Area2D = %Hitbox


func apply_level() -> void:
	pivot.scale.x = current_area() / data.area


func attack() -> void:
	var direction := aim_direction()
	if direction == Vector2.ZERO:
		return
	pivot.rotation = direction.angle()
	attacked.emit()
	await get_tree().physics_frame
	await get_tree().physics_frame
	for body in hitbox.get_overlapping_bodies():
		hit(body, direction * knockback)
