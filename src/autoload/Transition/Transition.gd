extends CanvasLayer

# Universal screen wipe. Scenes go through this instead of owning their own
# copy of the transition material + animations.

# Progress 0 = screen fully wiped black; the wipe clears as progress rises. The
# final value depends on the material's grid_size/progress_bias/position, so it is
# computed rather than hardcoded: retune the material freely.
const DURATION := 0.4

var _progress := 0.0

@onready var wipe: ColorRect = $Wipe


func _ready() -> void:
	_set_progress(0.0) # material may be saved mid-wipe; always start covered


func change_scene(path: String) -> void:
	await cover()
	if get_tree().change_scene_to_file(path) != OK:
		push_error("Transition: could not load %s" % path)
	await get_tree().process_frame # let the new scene enter the tree before revealing
	get_tree().paused = false
	reveal() # always reveal: a failed load must not leave the player on a black screen


func cover(duration: float = DURATION) -> void:
	wipe.visible = true
	await _wipe_to(0.0, duration)


func reveal(duration: float = DURATION) -> void:
	await _wipe_to(_clear_progress(), duration)
	wipe.visible = false


# Last progress needed: the cell with the highest stagger offset must still finish
# clearing its own 0..reach span, otherwise the far squares never finish.
# shortcut: exact for transition_type Basic with basic_feather 0, the configured
# settings; Mask/Shape/Clock need their own span if the material switches type.
func _clear_progress() -> float:
	var mat := wipe.material as ShaderMaterial
	var bias: Vector2 = mat.get_shader_parameter("progress_bias") / 10.0
	var last_cell: Vector2 = Vector2(mat.get_shader_parameter("grid_size")).ceil() - Vector2.ONE
	var p: Vector2 = mat.get_shader_parameter("position")
	var reach := 2.0 * maxf(maxf(p.x, 1.0 - p.x), maxf(p.y, 1.0 - p.y))
	return bias.dot(last_cell) + reach


func _wipe_to(target: float, duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(_set_progress, _progress, target, duration)
	await tween.finished


func _set_progress(value: float) -> void:
	_progress = value
	(wipe.material as ShaderMaterial).set_shader_parameter("progress", value)
