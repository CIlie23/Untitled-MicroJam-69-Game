extends WeaponNode

@export var orb_scene: PackedScene
@export var knockback: float = 80.0

@onready var ring: Node2D = %Ring
@onready var duration: Timer = %Duration


func begin() -> void:
	attack()


func _process(delta: float) -> void:
	ring.rotation += deg_to_rad(projectile_speed()) * delta


func apply_level() -> void:
	if ring.visible:
		spawn_orbs()


func attack() -> void:
	attacked.emit()
	spawn_orbs()
	ring.visible = true
	duration.start(data.duration)


func spawn_orbs() -> void:
	for orb in ring.get_children():
		orb.queue_free()
	var count := data.amount_at(level)
	for index in count:
		var orb: Area2D = orb_scene.instantiate()
		orb.position = Vector2.RIGHT.rotated(TAU * index / count) * current_area()
		orb.touched.connect(_on_orb_touched)
		ring.add_child(orb)


func _on_orb_touched(body: Node2D) -> void:
	hit(body, global_position.direction_to(body.global_position) * knockback)


func _on_duration_timeout() -> void:
	for orb in ring.get_children():
		orb.queue_free()
	ring.visible = false
	cooldown.start(current_cooldown())
