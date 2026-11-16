extends Area2D

signal touched(body: Node2D)


func _on_body_entered(body: Node2D) -> void:
	touched.emit(body)
