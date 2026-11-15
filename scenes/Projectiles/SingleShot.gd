extends Weapon
class_name SingleShot
 
func shoot(source, target, scene_tree):
	var aim = _aim_position(target)
	if aim == null:
		return
 
	var to_target: Vector2 = aim - source.position
	if to_target == Vector2.ZERO:
		return # cursor parked on the shooter: a zero direction never despawns
 
	var projectile = projectile_node.instantiate()
 
	projectile.position = source.position
	projectile.damage = damage
	projectile.speed = speed
	projectile.direction = to_target.normalized()
 
	scene_tree.current_scene.add_child(projectile)


# target is a node when the soul auto-aims, a world position when the mouse aims.
# is_instance_valid, not == null: a dead enemy leaves a freed, non-null ref.
func _aim_position(target):
	if target is Vector2:
		return target
	if is_instance_valid(target):
		return target.global_position
	return null
 
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
