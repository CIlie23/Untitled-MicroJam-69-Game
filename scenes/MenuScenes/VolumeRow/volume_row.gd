extends HBoxContainer

@export var bus_name: StringName = &"Master"
@export var title: String


func _ready() -> void:
	%Name.text = title
	%Slider.set_value_no_signal(AudioServer.get_bus_volume_linear(bus_index()) * 100.0)
	show_value()


func bus_index() -> int:
	return AudioServer.get_bus_index(bus_name)


func show_value() -> void:
	%Value.text = str(int(%Slider.value))


func _on_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(bus_index(), value / 100.0)
	show_value()
