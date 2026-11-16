extends Node2D

signal departed(at: Vector2)


func play_at(pos: Vector2) -> void:
	position = pos
	%Skeleton.position = Vector2.ZERO
	visible = true
	%AnimationPlayer.play(&"depart")


func _on_animation_player_animation_finished(_animation: StringName) -> void:
	visible = false
	departed.emit(%Skeleton.global_position)
