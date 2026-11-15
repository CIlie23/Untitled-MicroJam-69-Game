extends Node2D

# Possession is driven by the versus bar: the soul takes the body the moment it
# pulls ahead on strength, and the typing challenge is the one shot at typing it
# back out. Losing that attempt, or the soul building a full-bar lead, ends the run.

@export var words_per_haunt: int = 1
@export var words_per_level: int = 4 # one more word per this many levels, past level 3
@export var max_words: int = 5
@export var seconds_per_extra_word: float = 1.5
@export var revive_health: float = 30.0 # you come back on this much after an exorcism

@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	# in code, not the .tscn: a connection written for a direct child breaks
	# silently if the node is ever reparented
	%TypingChallenge.finished.connect(_on_typing_challenge_finished)
	%VersusBar.soul_took_over.connect(_on_soul_took_over)
	%VersusBar.soul_won.connect(_on_soul_won)


# one word until level 3, then one more every words_per_level levels, capped
func _words_for_level() -> int:
	if player.level < 3:
		return words_per_haunt
	var extra := floori((player.level - 3) / float(words_per_level))
	return mini(words_per_haunt + 1 + extra, max_words)


func _on_soul_took_over() -> void:
	# never interrupt a card pick or a dead run
	if player.dead or %PickCard.visible:
		return
	var words := _words_for_level()
	# the clock grows with the word count, so each word keeps roughly its 1.5s
	var duration: float = %TypingChallenge.seconds + words * seconds_per_extra_word
	if %TypingChallenge.start(words, duration):
		player.possessed = true
		%VersusBar.soul_farming = true # it grows while you type


func _on_typing_challenge_finished(success: bool) -> void:
	player.possessed = false
	%VersusBar.soul_farming = false
	if success:
		%VersusBar.exorcise()
		player.health = maxf(player.health, revive_health)
	else:
		# the soul keeps the body: run over
		player.die()


func _on_soul_won() -> void:
	player.die()
