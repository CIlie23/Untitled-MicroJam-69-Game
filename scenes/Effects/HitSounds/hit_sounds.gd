extends AudioStreamPlayer

@export var min_interval: float = 0.06

var since_last := 1.0


func _process(delta: float) -> void:
	since_last += delta


func play_hit() -> void:
	if since_last < min_interval:
		return
	since_last = 0.0
	play()
