extends Node2D
class_name Inventory

signal weapon_added(weapon: WeaponNode)
signal changed

@export var player: CharacterBody2D
@export var stats: PlayerStats
@export var base_attack: Weapon
@export var pool: Array[Item] = []
@export var max_weapons: int = 3
@export var max_passives: int = 6
@export var test_loadout: Array[Item] = []

var levels: Dictionary[Item, int] = {}
var weapon_nodes: Dictionary[Weapon, WeaponNode] = {}


func _ready() -> void:
	add_weapon(base_attack)
	equip_maxed(test_loadout)


func equip_maxed(items: Array[Item]) -> void:
	for item in items:
		while can_take(item):
			take(item)


func level_of(item: Item) -> int:
	return levels.get(item, 0)


func weapons() -> Array[Item]:
	return owned_where(func(item: Item) -> bool: return item is Weapon)


func passives() -> Array[Item]:
	return owned_where(func(item: Item) -> bool: return item is PassiveItem)


func owned_where(condition: Callable) -> Array[Item]:
	var result: Array[Item] = []
	result.assign(levels.keys().filter(condition))
	return result


func has_room_for(item: Item) -> bool:
	if item is Weapon:
		return weapons().size() < max_weapons
	return passives().size() < max_passives


func can_take(item: Item) -> bool:
	if level_of(item) >= item.max_level:
		return false
	return level_of(item) > 0 or has_room_for(item)


func offers(count: int, exclude: Array = []) -> Array[Item]:
	var candidates: Array[Item] = []
	for item in pool:
		if can_take(item) and not exclude.has(item):
			candidates.append(item)
	candidates.shuffle()
	return candidates.slice(0, count)


func take(item: Item) -> void:
	levels[item] = level_of(item) + 1
	if item is Weapon:
		level_weapon(item)
	else:
		stats.set_bonuses(passive_bonuses())
	changed.emit()


func level_weapon(weapon: Weapon) -> void:
	if weapon_nodes.has(weapon):
		weapon_nodes[weapon].set_level(level_of(weapon))
	else:
		add_weapon(weapon)


func add_weapon(weapon: Weapon) -> void:
	var node: WeaponNode = weapon.scene.instantiate()
	node.data = weapon
	node.level = maxi(1, level_of(weapon))
	node.stats = stats
	node.player = player
	weapon_nodes[weapon] = node
	add_child(node)
	weapon_added.emit(node)


func passive_bonuses() -> Dictionary[PassiveItem.Stat, float]:
	var result: Dictionary[PassiveItem.Stat, float] = {}
	for item: PassiveItem in passives():
		result[item.stat] = result.get(item.stat, 0.0) + item.amount_per_level * levels[item]
	return result
