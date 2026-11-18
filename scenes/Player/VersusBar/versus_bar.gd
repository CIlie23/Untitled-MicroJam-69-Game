extends Control

# Two souls, one body. Each side owns the fill behind it and the faces press
# together where the strengths meet: soul (purple) left, player (blue) right.

signal soul_took_over

const PAIR_OVERLAP := 12.0 # the faces are pressed into each other, soul in front

@export var possession_max: float = 100.0
@export var levels_to_possess: float = 2.0
@export var possession_enabled: bool = true
@export var exorcism_keep: float = 0.0

var possession := 0.0
var expelled := false
# set by the world while the soul has the body, so the takeover signal goes quiet
var soul_farming := false

@onready var soul_fill: ColorRect = $SoulFill
@onready var player_fill: ColorRect = $PlayerFill
@onready var soul_portrait: TextureRect = $EnemyPortrait
@onready var player_portrait: TextureRect = $PlayerPortrait


func _ready() -> void:
	resized.connect(_refresh) # size is still 0 during _ready
	_refresh()


func player_earned(amount: float, xp_per_level: float) -> void:
	_add(amount / (levels_to_possess * xp_per_level) * possession_max)


func exorcise() -> void:
	possession *= exorcism_keep
	_refresh()


func expel() -> void:
	expelled = true
	possession = 0.0
	_refresh()


func is_full() -> bool:
	return possession >= possession_max


func _add(amount: float) -> void:
	if expelled or not possession_enabled:
		return
	possession = minf(possession + amount, possession_max)
	_refresh()
	if is_full() and not soul_farming:
		soul_took_over.emit() # repeats until the world takes it, then goes quiet


func _refresh() -> void:
	var contact := possession / possession_max * size.x

	soul_fill.size.x = contact
	player_fill.position.x = contact
	player_fill.size.x = size.x - contact

	var pair := soul_portrait.size.x + player_portrait.size.x - PAIR_OVERLAP
	var pair_x := clampf(contact - pair * 0.5, 0.0, maxf(0.0, size.x - pair))
	soul_portrait.position.x = pair_x
	player_portrait.position.x = pair_x + soul_portrait.size.x - PAIR_OVERLAP
