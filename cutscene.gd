extends Node2D

# Two beats. On load, intro.dtl plays; its [signal] event pans the camera to the
# skeleton and back while the dialogue keeps running, and the timeline ending
# hands control to the player. Walking into the skeleton triggers the second
# beat: the red soul charges in from off-screen, blows the body open, and talks.

const INTRO := "res://cutscene/intro.dtl"
const RED_SOUL_DIAL := "res://cutscene/redSoul_dial1.dtl"
const WORLD := "res://scenes/world/world.tscn"

@export var pan_time := 1.0
@export var pan_hold := 1.5
@export var charge_time := 1.5
@export var explosion_time := 0.8
@export var beat_before_dialogue := 0.4
@export var challenge_words := 1
@export var retry_delay := 0.5

@onready var player: CharacterBody2D = $CutscenePlayer
@onready var camera: Camera2D = $CutscenePlayer/Camera2D
@onready var skeleton: Sprite2D = $Skeleton
@onready var red_soul: Sprite2D = $redSoul
@onready var explosion: Sprite2D = $Explosion
@onready var boom: AudioStreamPlayer = $ExplosionSound
@onready var arrow: Sprite2D = $Arrow
@onready var typing: Control = $UI/TypingChallenge

var _intro_done := false
var _second_beat := false
var _panning := false
var _pan_tween: Tween
var _leaving := false


func _ready() -> void:
	explosion.visible = false
	arrow.visible = false
	player.can_move = false # the intro talks before it says "press WASD"
	Dialogic.signal_event.connect(_on_dialogic_signal)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	typing.finished.connect(_on_typing_finished)
	Dialogic.start(INTRO)


func _process(_delta: float) -> void:
	# the arrow rides above the player and keeps pointing at the skeleton
	if not arrow.visible:
		return
	arrow.global_position = player.global_position + Vector2(0, -26)
	arrow.rotation = (skeleton.global_position - arrow.global_position).angle() + PI * 0.5 # art points up


func _on_dialogic_signal(argument: Variant) -> void:
	# the intro's signal pans the camera; redSoul_dial1's runs the typing beat
	if not _intro_done:
		if argument == "" or argument == "camera_skeleton":
			_pan_to_skeleton()
	elif argument == "" or argument == "typing_challenge":
		_start_typing()


# Holds the timeline mid-conversation: the event after the signal awaits
# dialogic_resumed, so the next line only plays once the player is done typing.
func _start_typing() -> void:
	Dialogic.paused = true
	if not typing.start(challenge_words):
		Dialogic.paused = false # no words configured: don't strand the dialogue


func _on_typing_finished(success: bool) -> void:
	if success:
		Dialogic.paused = false # the timeline picks up on the next line
		return
	# this beat is the tutorial for the mechanic, so a miss gets another go
	await get_tree().create_timer(retry_delay).timeout
	_start_typing()


func _on_timeline_ended() -> void:
	var was_intro := not _intro_done
	_intro_done = true
	# the intro's last line tells you to walk to the skeleton, so hand over control
	# once the camera is back on the player — not mid-pan
	if was_intro and _panning and _pan_tween:
		await _pan_tween.finished
	player.can_move = true
	if was_intro:
		arrow.visible = true # the intro's last line says to walk to the skeleton
		return
	_leave_for_world()


# second beat over: the wipe hands over to the run
func _leave_for_world() -> void:
	if _leaving:
		return
	_leaving = true
	player.can_move = false
	arrow.visible = false
	# the autoload outlives this scene, so a held timeline would follow us into the world
	Dialogic.paused = false
	Transition.change_scene(WORLD)


# the camera is a child of the player, so this is an offset in player space
func _pan_to_skeleton() -> void:
	if _panning:
		return
	_panning = true
	var offset := skeleton.global_position - player.global_position
	_pan_tween = create_tween()
	_pan_tween.tween_property(camera, "position", offset, pan_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pan_tween.tween_interval(pan_hold)
	_pan_tween.tween_property(camera, "position", Vector2.ZERO, pan_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await _pan_tween.finished
	_panning = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _second_beat or not _intro_done or body != player:
		return
	_second_beat = true
	player.can_move = false
	arrow.visible = false # arrived
	_charge_and_explode()


func _charge_and_explode() -> void:
	var tween := create_tween()
	tween.tween_property(red_soul, "global_position", skeleton.global_position, charge_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tween.finished
	_explode()
	await get_tree().create_timer(beat_before_dialogue).timeout
	Dialogic.start(RED_SOUL_DIAL)


func _explode() -> void:
	explosion.global_position = skeleton.global_position
	explosion.modulate.a = 1.0
	explosion.visible = true # drawn after the skeleton, so it lands on top of it
	boom.play()
	# sprite sheet: 4x7 frames played left to right, top to bottom
	var frames := explosion.hframes * explosion.vframes
	var roll := create_tween()
	roll.tween_method(func(f: float): explosion.frame = int(f), 0, frames - 1, explosion_time)
	roll.parallel().tween_property(explosion, "modulate:a", 0.0, explosion_time)
	roll.tween_callback(func(): explosion.visible = false)
