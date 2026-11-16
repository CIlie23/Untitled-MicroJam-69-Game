extends Overlay

const WORLD := "res://scenes/world/world.tscn"


func _on_mode_pressed(seconds: float) -> void:
	Global.run_length = seconds
	Transition.change_scene(WORLD)
