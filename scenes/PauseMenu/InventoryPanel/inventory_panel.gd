extends PanelContainer

@export var entry_scene: PackedScene


func refresh(inventory: Inventory, level: int) -> void:
	%Level.text = "LVL %d" % level
	%Stats.text = stats_text(inventory.stats)
	fill(%Weapons, inventory, inventory.weapons(), inventory.max_weapons)
	fill(%Passives, inventory, inventory.passives(), inventory.max_passives)


func stats_text(stats: PlayerStats) -> String:
	var lines: PackedStringArray = []
	for stat: PassiveItem.Stat in PassiveItem.STAT_NAMES:
		lines.append("%s: %s" % [PassiveItem.STAT_NAMES[stat], PassiveItem.format_bonus(stat, stats.bonus(stat))])
	return "\n".join(lines)


func fill(row: HBoxContainer, inventory: Inventory, items: Array[Item], slots: int) -> void:
	for child in row.get_children():
		child.queue_free()
	for index in slots:
		var entry: TextureRect = entry_scene.instantiate()
		var level_label: Label = entry.get_node("Level")
		level_label.text = ""
		if index < items.size():
			entry.texture = items[index].texture
			level_label.text = str(inventory.level_of(items[index]))
		row.add_child(entry)
