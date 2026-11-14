extends Control


func _on_play_pressed() -> void:
	Transition.change_scene("res://scenes/world/world.tscn")


func _on_options_pressed() -> void:
	Transition.change_scene("res://scenes/settings_menu.tscn")


func _on_credits_pressed() -> void:
	Transition.change_scene("res://scenes/credits_menu.tscn")
