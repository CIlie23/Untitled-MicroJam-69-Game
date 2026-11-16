extends Node2D

# Possession is driven by the versus bar: the soul takes the body once the bar
# fills to its end, and the typing challenge is the one shot at typing it back
# out. Losing that attempt ends the run.

signal soul_expelled

@export var words_per_haunt: int = 1
@export var words_per_level: int = 4 # one more word per this many levels, past level 3
@export var max_words: int = 5
@export var seconds_per_extra_word: float = 1.5
@export var run_length: float = 1800.0
@export var possession_bonus_time: float = 5.0
@export var boss_appear_delay: float = 1.0
@export var boss_hp_per_stolen_xp: float = 25.0
@export var test_start_time: float = 0.0
@export var victory_delay: float = 15.0
@export var music_fade_time: float = 1.5

var run_time := 0.0
var soul_gone := false
var kills := 0

@onready var player: CharacterBody2D = $Player


func _process(delta: float) -> void:
	# delta, not wall clock: the clock stops whenever the tree is paused
	run_time += delta
	%timeLabel.text = _format_time(time_left())
	if time_left() <= 0.0 and not soul_gone:
		expel_soul()


func time_left() -> float:
	return maxf(0.0, run_length - run_time)


func _format_time(seconds: float) -> String:
	return "%02d:%02d" % [floori(seconds / 60.0), int(seconds) % 60]


func _ready() -> void:
	run_length = Global.run_length
	%Spawner.set_run_length(run_length)
	run_time = test_start_time
	%Spawner.elapsed = test_start_time * %Spawner.pace
	# in code, not the .tscn: a connection written for a direct child breaks
	# silently if the node is ever reparented
	%TypingChallenge.finished.connect(_on_typing_challenge_finished)
	%VersusBar.soul_took_over.connect(_on_soul_took_over)


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
	var duration: float = %TypingChallenge.seconds + words * seconds_per_extra_word + possession_bonus_time
	if %TypingChallenge.start(words, duration):
		player.possessed = true
		%VersusBar.soul_farming = true


func _on_typing_challenge_finished(success: bool) -> void:
	player.possessed = false
	%VersusBar.soul_farming = false
	if success:
		%VersusBar.exorcise()
	else:
		# the soul keeps the body: run over
		player.die()


func expel_soul() -> void:
	soul_gone = true
	%VersusBar.expel()
	if player.possessed:
		%TypingChallenge.stop()
		_on_typing_challenge_finished(true)
	soul_expelled.emit()
	begin_final_cutscene()


func begin_final_cutscene() -> void:
	%Spawner.end_regular_spawns()
	clear_enemies()
	player.controls_locked = true
	%SoulDeparture.play_at(player.position)


func clear_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group(&"Enemy"):
		enemy.queue_free()


func _on_soul_departure_departed(at: Vector2) -> void:
	await get_tree().create_timer(boss_appear_delay, false).timeout
	var boss: Node2D = %Spawner.spawn_final_boss_at(at)
	boss.health += player.stolen_xp * boss_hp_per_stolen_xp
	player.controls_locked = false


func count_kill() -> void:
	kills += 1


func start_boss_music() -> void:
	var tween := create_tween()
	tween.tween_property(%Music, "volume_db", -40.0, music_fade_time)
	tween.tween_callback(%Music.stop)
	%BossMusic.play()


func run_stats() -> Dictionary:
	return {
		"Time survived": _format_time(run_time),
		"Level": player.level,
		"Enemies slain": kills,
		"Souls collected": player.souls,
		"XP stolen by the soul": roundi(player.stolen_xp),
	}


func _on_spawner_final_boss_spawned(_boss: Node2D) -> void:
	start_boss_music()


func _on_spawner_final_boss_died() -> void:
	%LichDeathSound.play()
	clear_enemies.call_deferred()
	await get_tree().create_timer(victory_delay, false).timeout
	%VictoryScreen.show_victory(run_stats())
