extends Overlay


func _ready() -> void:
	%ResolutionRow.visible = not OS.has_feature("web")


func open() -> void:
	refresh_keybinds()
	%Fullscreen.set_pressed_no_signal(is_fullscreen())
	select_current_resolution()
	super()


func refresh_keybinds() -> void:
	%ArrowKeys.set_pressed_no_signal(%UpRow.uses_arrow_key())
	for row: KeybindRow in %KeybindRows.get_children():
		row.refresh()


func is_fullscreen() -> bool:
	return get_window().mode == Window.MODE_FULLSCREEN


func resolution_at(index: int) -> Vector2i:
	var parts: PackedStringArray = %Resolution.get_item_text(index).split("x")
	return Vector2i(int(parts[0]), int(parts[1]))


func select_current_resolution() -> void:
	for index in %Resolution.item_count:
		if resolution_at(index) == get_window().size:
			%Resolution.select(index)
			return
	%Resolution.select(-1)


func _on_arrow_keys_toggled(toggled_on: bool) -> void:
	for row: KeybindRow in %KeybindRows.get_children():
		row.use_scheme(toggled_on)


func _on_resolution_item_selected(index: int) -> void:
	get_window().size = resolution_at(index)
	get_window().move_to_center()


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
