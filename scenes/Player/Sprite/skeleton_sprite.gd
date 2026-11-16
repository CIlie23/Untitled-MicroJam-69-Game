extends AnimatedSprite2D

@export var player_color: Color = Color(0.3, 0.6, 1.0)
@export var soul_color: Color = Color(1.0, 0.2, 0.2)


func _ready() -> void:
	show_soul(false)


func show_motion(velocity: Vector2) -> void:
	play(&"walk" if velocity != Vector2.ZERO else &"idle")
	if velocity.x != 0.0:
		flip_h = velocity.x > 0.0


func show_soul(possessed: bool) -> void:
	material.set_shader_parameter("soul_color", soul_color if possessed else player_color)


func _on_player_hurt() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(2.0, 0.4, 0.4), 0.06)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _on_player_possession_changed(possessed: bool) -> void:
	show_soul(possessed)
