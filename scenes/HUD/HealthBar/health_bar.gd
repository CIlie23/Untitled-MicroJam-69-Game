extends ProgressBar


func _on_player_health_changed(health: float, max_health: float) -> void:
	max_value = max_health
	value = health
	%HealthText.text = "%d / %d" % [ceili(snappedf(health, 0.01)), roundi(max_health)]
