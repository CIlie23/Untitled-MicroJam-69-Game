extends StaticBody2D

const PICKUP_SCENE := preload("res://scenes/Xp/pickups.tscn")

@export var health: float = 40.0
@export var drop: Pickups

var knockback := Vector2.ZERO
var broken := false


func take_damage(amount: float, _crit := false) -> void:
	if broken:
		return
	health -= amount
	ParticleFX.emit_at(self, &"spark", global_position)
	flash()
	if health <= 0.0:
		break_apart()


func flash() -> void:
	var tween := create_tween()
	tween.tween_property(%Sprite2D, "modulate", Color(2, 2, 2), 0.08)
	tween.tween_property(%Sprite2D, "modulate", Color.WHITE, 0.12)


func break_apart() -> void:
	broken = true
	ParticleFX.emit_at(self, &"dust", global_position)
	if drop:
		spawn_drop()
	queue_free()


func spawn_drop() -> void:
	var pickup = PICKUP_SCENE.instantiate()
	pickup.type = drop
	pickup.player_reference = get_tree().get_first_node_in_group(&"Player")
	pickup.position = position
	get_parent().add_child.call_deferred(pickup)
