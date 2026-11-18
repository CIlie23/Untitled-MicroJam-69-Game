extends ColorRect

@export var flash_intensity: float = 0.8
@export var fade_time: float = 0.45

var tween: Tween


func _on_player_hurt() -> void:
	if tween:
		tween.kill()
	material.set_shader_parameter("intensity", flash_intensity)
	tween = create_tween()
	tween.tween_method(set_intensity, flash_intensity, 0.0, fade_time)


func set_intensity(value: float) -> void:
	material.set_shader_parameter("intensity", value)
