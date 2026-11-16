extends Node2D

@export var target: Node2D
@export var period: Vector2 = Vector2(2048, 1280)


func _physics_process(_delta: float) -> void:
	for prop: Node2D in get_children():
		prop.position += wrap_shift(prop.global_position - target.global_position)


func wrap_shift(offset: Vector2) -> Vector2:
	var shift := Vector2.ZERO
	if absf(offset.x) > period.x * 0.5:
		shift.x = -signf(offset.x) * period.x
	if absf(offset.y) > period.y * 0.5:
		shift.y = -signf(offset.y) * period.y
	return shift
