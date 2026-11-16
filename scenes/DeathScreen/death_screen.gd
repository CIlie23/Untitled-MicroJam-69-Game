extends Control

# Shown when the player dies. Pauses the tree, so the scene root is
# PROCESS_MODE_WHEN_PAUSED and the buttons still take clicks.

const WORLD := "res://scenes/world/world.tscn"
const MAIN_MENU := "res://scenes/MenuScenes/main_menu.tscn"


func show_death() -> void:
	if visible:
		return
	visible = true
	get_tree().paused = true


func _on_retry_pressed() -> void:
	Transition.change_scene(WORLD)


func _on_menu_pressed() -> void:
	Transition.change_scene(MAIN_MENU)
