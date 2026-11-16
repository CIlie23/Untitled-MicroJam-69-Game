extends HBoxContainer

@export var bar_scene: PackedScene


func _on_inventory_weapon_added(weapon: WeaponNode) -> void:
	var bar := bar_scene.instantiate()
	bar.weapon = weapon
	add_child(bar)
