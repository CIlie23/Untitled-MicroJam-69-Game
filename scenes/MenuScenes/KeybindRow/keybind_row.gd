extends HBoxContainer
class_name KeybindRow

@export var action: StringName
@export var title: String
@export var wasd_key: Key
@export var arrow_key: Key

var listening := false


func _ready() -> void:
	%Name.text = title
	refresh()


func refresh() -> void:
	%Key.text = OS.get_keycode_string(bound_key())


func bound_key() -> Key:
	for event: InputEvent in InputMap.action_get_events(action):
		if event is InputEventKey:
			return (event as InputEventKey).physical_keycode
	return KEY_NONE


func uses_arrow_key() -> bool:
	return bound_key() == arrow_key


func use_scheme(arrows: bool) -> void:
	bind(arrow_key if arrows else wasd_key)


func bind(key: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = key
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	refresh()


func _on_key_pressed() -> void:
	listening = true
	%Key.text = "..."


func _input(event: InputEvent) -> void:
	if not listening or not is_key_press(event):
		return
	get_viewport().set_input_as_handled()
	listening = false
	var key: Key = (event as InputEventKey).physical_keycode
	if key != KEY_ESCAPE:
		bind(key)
	refresh()


func is_key_press(event: InputEvent) -> bool:
	return event is InputEventKey and event.pressed and not event.echo
