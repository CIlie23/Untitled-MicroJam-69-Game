extends Overlay

const CUTSCENE := "res://cutscene/tscn/cutscene.tscn"


func _on_mode_pressed(seconds: float) -> void:
	Global.run_length = seconds
	Transition.change_scene(CUTSCENE)
