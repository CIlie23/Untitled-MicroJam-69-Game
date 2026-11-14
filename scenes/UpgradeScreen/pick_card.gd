extends Control

# Level-up upgrade pick. The tree is paused while this is open, so the scene root
# is PROCESS_MODE_WHEN_PAUSED and nothing here may depend on the game ticking.

@onready var card_row: HBoxContainer = $HBoxContainer


func _ready() -> void:
	for card in card_row.get_children():
		card.pressed.connect(_on_card_pressed.bind(card))


func show_options() -> void:
	if visible:
		return # already picking: a multi-level gain gets one screen, not N
	visible = true
	get_tree().paused = true


func _on_card_pressed(card: Button) -> void:
	# upgrades do nothing yet; `card` is the choice
	close()


func close() -> void:
	visible = false
	get_tree().paused = false
