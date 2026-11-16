extends Control


func _ready() -> void:
	%Quit.visible = not OS.has_feature("web")


func _on_play_pressed() -> void:
	%ModeSelect.open()


func _on_options_pressed() -> void:
	%SettingsMenu.open()


func _on_credits_pressed() -> void:
	%Credits.open()


func _on_quit_pressed() -> void:
	get_tree().quit()
