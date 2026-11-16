extends Node2D
class_name ParticleFX

@export var effects: Dictionary[StringName, PackedScene] = {}
@export var max_active: int = 40

var active: Dictionary[StringName, int] = {}


static func emit_at(from: Node, effect_name: StringName, pos: Vector2) -> void:
	var fx := from.get_tree().get_first_node_in_group(&"particle_fx") as ParticleFX
	if fx:
		fx.add_effect(effect_name, pos)


func add_effect(effect_name: StringName, pos: Vector2, parent: Node = null) -> void:
	if not effects.has(effect_name):
		push_warning("ParticleFX: effect '%s' not found" % effect_name)
		return
	if active.get(effect_name, 0) >= max_active:
		return
	var particles: Node2D = effects[effect_name].instantiate()
	particles.position = pos
	active[effect_name] = active.get(effect_name, 0) + 1
	particles.tree_exited.connect(_on_effect_exited.bind(effect_name))
	(parent if parent else self).add_child.call_deferred(particles)


func _on_effect_exited(effect_name: StringName) -> void:
	active[effect_name] -= 1
