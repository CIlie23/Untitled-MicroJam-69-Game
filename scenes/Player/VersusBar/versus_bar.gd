extends Control

# Two souls, one body. Each side owns the fill behind it and the faces press
# together where the strengths meet: soul (purple) left, player (blue) right.
#
# Kills feed both souls because they share the body, but the player keeps the
# larger share; damage only ever eats the player's side. The moment the soul
# pulls ahead it takes the body (soul_took_over) and the player has to type it
# back out (exorcise). Let the soul build a full-bar lead and the run is over.

signal soul_took_over
signal soul_won

const PAIR_OVERLAP := 10.0 # the faces are pressed into each other, soul in front

@export var starting_power: float = 20.0
@export var soul_starting_power: float = 10.0
@export var power_per_xp: float = 1.0 # player's share of a kill
@export var soul_share_per_xp: float = 0.5 # the soul's share while the player drives
@export var power_per_damage: float = 0.25
@export var exorcism_keep: float = 0.5 # soul keeps this much when typed out
@export var soul_power_per_second: float = 2.0 # it grows while it holds the body
@export var lose_lead: float = 60.0 # soul lead that ends the run outright

var player_power := 0.0
var soul_power := 0.0
# set by the world while the soul has the body: it farms on its own, and the
# takeover signal goes quiet so it isn't emitted every frame
var soul_farming := false
var _lost := false

@onready var soul_fill: ColorRect = $SoulFill
@onready var player_fill: ColorRect = $PlayerFill
@onready var soul_portrait: TextureRect = $EnemyPortrait
@onready var player_portrait: TextureRect = $PlayerPortrait


func _process(delta: float) -> void:
	if not soul_farming:
		return
	soul_power += soul_power_per_second * delta
	_check()


func _ready() -> void:
	player_power = starting_power
	soul_power = soul_starting_power
	resized.connect(_refresh) # size is still 0 during _ready
	_refresh()


# gems the body collected while the player was driving
func player_earned(amount: float) -> void:
	player_power += power_per_xp * amount
	soul_power += soul_share_per_xp * amount
	_check()


# gems the body collected while the soul was driving: it farms alone
func soul_earned(amount: float) -> void:
	soul_power += power_per_xp * amount
	_check()


func player_hurt(amount: float) -> void:
	# floored at 0: a negative side would trip lose_lead on the next hit and
	# leave exorcise() unable to put the player back in front
	player_power = maxf(0.0, player_power - power_per_damage * amount)
	_check()


# out of health: the player's soul is spent, so the soul is put ahead of it
func player_downed() -> void:
	player_power = minf(player_power, soul_power - 1.0)
	_check()


# typed the soul back out: you reassert a foothold, the soul keeps a fraction of
# its strength and never more than you, so it cannot take the body straight back
func exorcise() -> void:
	player_power = maxf(player_power, starting_power * 0.5)
	soul_power = maxf(0.0, minf(soul_power * exorcism_keep, player_power - 1.0))
	_check()


func _check() -> void:
	_refresh()
	# once, not per event: the loss handler damages the player, which lands back
	# here through player_hurt and would recurse forever
	if _lost:
		return
	if soul_power - player_power >= lose_lead:
		_lost = true
		soul_won.emit()
	elif soul_power > player_power and not soul_farming:
		soul_took_over.emit() # repeats until the world takes it, then goes quiet


func _refresh() -> void:
	# half the bar at a tie, all of it when leading by lose_lead
	var player_share := clampf(0.5 + (player_power - soul_power) / (2.0 * lose_lead), 0.0, 1.0)
	var contact := (1.0 - player_share) * size.x

	soul_fill.size.x = contact
	player_fill.position.x = contact
	player_fill.size.x = size.x - contact

	var pair := soul_portrait.size.x + player_portrait.size.x - PAIR_OVERLAP
	var pair_x := clampf(contact - pair * 0.5, 0.0, maxf(0.0, size.x - pair))
	soul_portrait.position.x = pair_x
	player_portrait.position.x = pair_x + soul_portrait.size.x - PAIR_OVERLAP
