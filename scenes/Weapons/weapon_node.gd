extends Node2D
class_name WeaponNode

signal attacked

var data: Weapon
var level: int = 1
var stats: PlayerStats
var player: CharacterBody2D

@onready var cooldown: Timer = %Cooldown


func _ready() -> void:
	stats.changed.connect(apply_level)
	apply_level()
	begin()


func begin() -> void:
	cooldown.start(current_cooldown())


func set_level(value: int) -> void:
	level = value
	apply_level()


func apply_level() -> void:
	pass


func attack() -> void:
	pass


func current_cooldown() -> float:
	return data.cooldown_at(level) / stats.multiplier(PassiveItem.Stat.ATTACK_SPEED)


func current_area() -> float:
	return data.area_at(level) * stats.multiplier(PassiveItem.Stat.AREA)


func projectile_speed() -> float:
	return data.speed_at(level) * stats.multiplier(PassiveItem.Stat.PROJECTILE_SPEED)


func aim_position() -> Variant:
	if not player.possessed:
		return get_global_mouse_position()
	if is_instance_valid(player.nearest_enemy):
		return player.nearest_enemy.global_position
	return null


func aim_direction() -> Vector2:
	var aim: Variant = aim_position()
	if aim == null:
		return Vector2.ZERO
	return global_position.direction_to(aim)


func hit(body: Node2D, push: Vector2 = Vector2.ZERO) -> void:
	if not body.has_method("take_damage"):
		return
	stats.deal_damage(body, data.damage_at(level))
	body.knockback = push


func _on_cooldown_timeout() -> void:
	cooldown.wait_time = current_cooldown()
	attack()
