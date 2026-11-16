extends Control
class_name Overlay

signal closed

@export var fade_time: float = 0.15

var is_open := false


func open() -> void:
	is_open = true
	visible = true
	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, fade_time)


func close() -> void:
	is_open = false
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, fade_time)
	await tween.finished
	visible = false
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close()


func _on_back_pressed() -> void:
	close()
