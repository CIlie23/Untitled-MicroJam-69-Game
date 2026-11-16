extends Control

const WORLD := "res://scenes/world/world.tscn"
const MAIN_MENU := "res://scenes/MenuScenes/main_menu.tscn"


func show_victory(stats: Dictionary) -> void:
	%Stats.text = stats_text(stats)
	visible = true
	get_tree().paused = true


func stats_text(stats: Dictionary) -> String:
	var lines: PackedStringArray = []
	for label in stats:
		lines.append("%s: %s" % [label, stats[label]])
	return "\n".join(lines)


func _on_continue_pressed() -> void:
	Transition.change_scene(MAIN_MENU)


func _on_retry_pressed() -> void:
	Transition.change_scene(WORLD)
