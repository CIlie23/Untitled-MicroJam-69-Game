extends Overlay

const WORLD := "res://scenes/world/world.tscn"
const MAIN_MENU := "res://scenes/MenuScenes/main_menu.tscn"

@export var player: CharacterBody2D
@export var inventory: Inventory


func _input(event: InputEvent) -> void:
	if not is_open and event.is_action_pressed("ui_cancel") and can_pause():
		get_viewport().set_input_as_handled()
		open()


func can_pause() -> bool:
	return not get_tree().paused


func open() -> void:
	get_tree().paused = true
	%InventoryPanel.refresh(inventory, player.level)
	super()


func close() -> void:
	await super()
	get_tree().paused = false


func _on_pause_button_pressed() -> void:
	if can_pause():
		open()


func _on_resume_pressed() -> void:
	close()


func _on_retry_pressed() -> void:
	Transition.change_scene(WORLD)


func _on_options_pressed() -> void:
	%SettingsMenu.open()


func _on_quit_pressed() -> void:
	Transition.change_scene(MAIN_MENU)
