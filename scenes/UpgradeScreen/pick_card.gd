extends Control

# Level-up upgrade pick. The tree is paused while this is open, so the scene root
# is PROCESS_MODE_WHEN_PAUSED and nothing here may depend on the game ticking.

signal cards_dealt

@export var inventory: Inventory

var offered: Array[Item] = []

@onready var columns: Array[VBoxContainer] = [%Column, %Column2, %Column3]


func show_options() -> void:
	if visible:
		return # already picking: a multi-level gain gets one screen, not N
	offered = inventory.offers(columns.size())
	for index in columns.size():
		show_column(index)
	cards_dealt.emit()
	visible = true
	get_tree().paused = true


func is_trick() -> bool:
	return offered.is_empty()


func show_column(index: int) -> void:
	var column := columns[index]
	var card: Button = column.get_node("Card")
	var reroll: Button = column.get_node("Reroll")
	reroll.disabled = false
	reroll.visible = not is_trick()
	if is_trick():
		column.visible = true
		card.show_trick()
		return
	column.visible = index < offered.size()
	if column.visible:
		show_offer(index)


func show_offer(index: int) -> void:
	var item := offered[index]
	columns[index].get_node("Card").show_item(item, inventory.level_of(item) + 1)


func _on_card_pressed(index: int) -> void:
	if not is_trick():
		inventory.take(offered[index])
	close()


func _on_reroll_pressed(index: int) -> void:
	columns[index].get_node("Reroll").disabled = true
	var replacements := inventory.offers(1, offered)
	if replacements.is_empty():
		return
	offered[index] = replacements[0]
	show_offer(index)
	cards_dealt.emit()


func close() -> void:
	visible = false
	get_tree().paused = false
