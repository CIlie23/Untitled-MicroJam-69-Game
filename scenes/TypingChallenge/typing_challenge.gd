extends Control

# Haunting prompt: the player loses control and must type one word per heart
# before the clock runs out. Control and damage belong to the caller — this only
# reports back.

signal finished(success: bool)

# open/close pairs, one picked per challenge. Colours nest inside them.
const WORD_EFFECTS := [
	["[tornado radius=10.0 freq=1.0 connected=1]", "[/tornado]"],
	["[shake rate=20.0 level=5 connected=1]", "[/shake]"],
	["[fade start=4 length=14]", "[/fade]"],
]

@export var words: PackedStringArray = ["haunt", "soul", "possess", "grave", "whisper", "candle", "vanish"]
@export var seconds: float = 6.0

# one heart per word; the caller raises the count as the run gets harder
@export var heart_empty: Texture2D
@export var heart_full: Texture2D

var running := false
var target := ""
var time_left := 0.0
var effect: Array = WORD_EFFECTS[0]
var required := 1
var typed := 0

@onready var word_label: RichTextLabel = $VBoxContainer/RichTextLabel
@onready var line_edit: LineEdit = $VBoxContainer/LineEdit
@onready var time_bar: ProgressBar = $TimeBar
@onready var life_bar: HBoxContainer = $VBoxContainer/LifeBar


func _ready() -> void:
	visible = false
	line_edit.text_changed.connect(_on_text_changed)
	line_edit.focus_exited.connect(_regrab_focus)
	# F6 on this scene alone: run a challenge, so it can be tuned without the game
	if get_parent() == get_tree().root:
		start(2) # 2 hearts, so the row is visible while tuning


func start(words_needed: int = 1, duration: float = -1.0) -> bool:
	if running:
		return false
	if words.is_empty():
		push_error("TypingChallenge: words is empty")
		return false
	running = true
	required = maxi(1, words_needed)
	typed = 0
	_build_hearts(required)
	time_left = seconds if duration < 0.0 else duration
	time_bar.max_value = time_left
	time_bar.value = time_left
	line_edit.grab_focus()
	_next_word()
	visible = true
	return true


# Typing is the whole mechanic, so losing the caret mid-challenge means losing.
# Covers clicks outside the field and any Enter the scene settings miss.
func _regrab_focus() -> void:
	if running and not get_tree().paused:
		line_edit.grab_focus.call_deferred()


func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		_regrab_focus()


func stop() -> void:
	running = false
	visible = false
	line_edit.text = ""
	line_edit.release_focus()


func _process(delta: float) -> void:
	if not running:
		return
	# delta, not wall clock: the clock stops whenever the tree is paused
	time_left -= delta
	time_bar.value = time_left
	if time_left <= 0.0:
		_finish(false)


func _on_text_changed(new_text: String) -> void:
	if not running:
		return
	if new_text.strip_edges() == target:
		_word_done()
		return
	_draw_word(new_text)


func _word_done() -> void:
	typed += 1
	life_bar.get_child(typed - 1).texture = heart_full
	if typed >= required:
		_finish(true)
	else:
		_next_word()


func _next_word() -> void:
	target = words[randi() % words.size()]
	effect = WORD_EFFECTS[randi() % WORD_EFFECTS.size()]
	line_edit.text = "" # re-enters here with "", which only redraws
	_draw_word("")


func _build_hearts(count: int) -> void:
	for heart in life_bar.get_children():
		life_bar.remove_child(heart)
		heart.queue_free()
	for i in count:
		var heart := TextureRect.new()
		heart.texture = heart_empty
		life_bar.add_child(heart)


func _finish(success: bool) -> void:
	stop()
	finished.emit(success)


func _draw_word(typed: String) -> void:
	var matched := ""
	while matched.length() < typed.length() and matched.length() < target.length() \
			and typed[matched.length()] == target[matched.length()]:
		matched += target[matched.length()]
	var rest := target.substr(matched.length())
	var junk := typed.substr(matched.length())
	var body := "[color=lime]%s[/color]%s" % [matched, rest]
	if junk != "":
		body += "[color=red]%s[/color]" % junk
	word_label.text = effect[0] + body + effect[1]
