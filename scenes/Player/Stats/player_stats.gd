extends Node
class_name PlayerStats

signal changed

@export var crit_multiplier: float = 2.0

var bonuses: Dictionary[PassiveItem.Stat, float] = {}


func set_bonuses(value: Dictionary[PassiveItem.Stat, float]) -> void:
	bonuses = value
	changed.emit()


func bonus(stat: PassiveItem.Stat) -> float:
	return bonuses.get(stat, 0.0)


func multiplier(stat: PassiveItem.Stat) -> float:
	return 1.0 + bonus(stat)


func deal_damage(target: Node2D, base: float) -> void:
	var amount := base * multiplier(PassiveItem.Stat.DAMAGE)
	var crit := randf() < bonus(PassiveItem.Stat.CRIT_CHANCE)
	if crit:
		amount *= crit_multiplier
	target.take_damage(amount, crit)
