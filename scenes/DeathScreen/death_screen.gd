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
	_leave(WORLD)


func _on_menu_pressed() -> void:
	_leave(MAIN_MENU)


# The pause state survives change_scene, so lift it once the new scene is in.
# Unpausing only after the wipe means a failed load still lands on a playable scene.
# `tree` up front: change_scene frees this node, so get_tree() is gone after the await.
func _leave(path: String) -> void:
	var tree := get_tree()
	await Transition.change_scene(path)
	tree.paused = false
