extends Control

const MAIN_MENU := "res://scenes/MenuScenes/main_menu.tscn"


func _on_back_pressed() -> void:
	Transition.change_scene(MAIN_MENU)
