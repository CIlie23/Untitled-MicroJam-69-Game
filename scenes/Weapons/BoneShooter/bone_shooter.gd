extends WeaponNode

@export var projectile_scene: PackedScene
@export var spread_degrees: float = 12.0


func attack() -> void:
	var direction := aim_direction()
	if direction == Vector2.ZERO:
		return
	attacked.emit()
	var count := data.amount_at(level)
	for index in count:
		var offset := (index - (count - 1) / 2.0) * deg_to_rad(spread_degrees)
		shoot(direction.rotated(offset))


func shoot(direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	projectile.direction = direction
	projectile.speed = projectile_speed()
	projectile.damage = data.damage_at(level)
	projectile.stats = stats
	get_tree().current_scene.add_child(projectile)
