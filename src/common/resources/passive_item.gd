extends Item
class_name PassiveItem

enum Stat { ATTACK_SPEED, MOVE_SPEED, PROJECTILE_SPEED, MAX_HEALTH, XP_GAIN, DAMAGE, CRIT_CHANCE, PICKUP_RANGE, AREA, HP_REGEN }

const STAT_NAMES: Dictionary[Stat, String] = {
	Stat.ATTACK_SPEED: "Attack Speed",
	Stat.MOVE_SPEED: "Move Speed",
	Stat.PROJECTILE_SPEED: "Projectile Speed",
	Stat.MAX_HEALTH: "Max Health",
	Stat.XP_GAIN: "XP Gain",
	Stat.DAMAGE: "Damage",
	Stat.CRIT_CHANCE: "Crit Chance",
	Stat.PICKUP_RANGE: "Pickup Range",
	Stat.AREA: "Area",
	Stat.HP_REGEN: "HP Regen",
}

@export var stat: Stat
@export var amount_per_level: float = 0.1


func card_text(_level: int) -> String:
	return "%s\n[color=green]%s[/color] %s" % [description, format_bonus(stat, amount_per_level), STAT_NAMES[stat]]


static func format_bonus(bonus_stat: Stat, value: float) -> String:
	if bonus_stat == Stat.HP_REGEN:
		return "+%.1f/s" % value
	return "+%d%%" % roundi(value * 100.0)
