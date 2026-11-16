extends Item
class_name Weapon

@export var scene: PackedScene

@export_group("Base")
@export var damage: float = 5.0
@export var cooldown: float = 1.0
@export var speed: float = 300.0
@export var amount: int = 1
@export var amount_name: String = "projectile"
@export var area: float = 50.0
@export var duration: float = 0.0

@export_group("Per Level")
@export var damage_per_level: float = 1.0
@export_range(0.0, 0.5) var cooldown_per_level: float = 0.0
@export var area_per_level: float = 0.0
@export var speed_per_level: float = 0.0
@export var amount_levels: Array[int] = []


func damage_at(level: int) -> float:
	return damage + damage_per_level * (level - 1)


func cooldown_at(level: int) -> float:
	return cooldown * pow(1.0 - cooldown_per_level, level - 1)


func speed_at(level: int) -> float:
	return speed + speed_per_level * (level - 1)


func area_at(level: int) -> float:
	return area + area_per_level * (level - 1)


func amount_at(level: int) -> int:
	var extra := 0
	for unlock_level in amount_levels:
		if unlock_level <= level:
			extra += 1
	return amount + extra


func card_text(level: int) -> String:
	if level <= 1:
		return description
	return "\n".join(upgrade_lines(level))


func upgrade_lines(level: int) -> PackedStringArray:
	var lines: PackedStringArray = []
	if damage_per_level > 0.0:
		lines.append("[color=green]+%s[/color] Damage" % damage_per_level)
	if cooldown_per_level > 0.0:
		lines.append("[color=green]%d%%[/color] Faster" % roundi(cooldown_per_level * 100.0))
	if speed_per_level > 0.0:
		lines.append("[color=green]+%d[/color] Speed" % roundi(speed_per_level))
	if area_per_level > 0.0:
		lines.append("[color=green]+%d[/color] Area" % roundi(area_per_level))
	if amount_at(level) > amount_at(level - 1):
		lines.append("[color=green]+1[/color] %s" % amount_name.capitalize())
	return lines
