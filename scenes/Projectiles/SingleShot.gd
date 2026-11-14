extends Weapon
class_name SingleShot
 
func shoot(source, target, scene_tree):
	# is_instance_valid, not == null: a dead enemy leaves a freed, non-null ref
	if not is_instance_valid(target):
		return
 
	var projectile = projectile_node.instantiate()
 
	projectile.position = source.position
	projectile.damage = damage
	projectile.speed = speed
	projectile.direction = (target.position - source.position).normalized()
 
	scene_tree.current_scene.add_child(projectile)
 
func activate(source, target, scene_tree):
	shoot(source, target, scene_tree)
