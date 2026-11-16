extends Node2D

static var sounds_playing := 0

@export var max_sounds: int = 6

var sound: AudioStream
var counted := false


func _ready() -> void:
	%Burst.play()
	if sound and sounds_playing < max_sounds:
		counted = true
		sounds_playing += 1
		%Sound.stream = sound
		%Sound.play()


func _exit_tree() -> void:
	if counted:
		sounds_playing -= 1


func is_done() -> bool:
	return not %Burst.is_playing() and not %Sound.playing


func _on_burst_animation_finished() -> void:
	%Burst.visible = false
	if is_done():
		queue_free()


func _on_sound_finished() -> void:
	if is_done():
		queue_free()
