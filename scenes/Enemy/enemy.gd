extends CharacterBody2D

signal died

const PICKUP_SCENE := preload("res://scenes/Xp/pickups.tscn")
const ELITE_DROP := preload("res://data/items/big_xp_gem.tres")
const HEAL_DROP := preload("res://data/items/heal_orb.tres")
const DEATH_FX := preload("res://scenes/Enemy/DeathFx/death_fx.tscn")
const CHASE := preload("res://scenes/Enemy/Movement/chase_movement.tscn")
const EXPLOSION := preload("res://scenes/Enemy/Abilities/lich_blast.tscn")
const ENEMY_SCENE_PATH := "res://scenes/Enemy/enemy.tscn"

@export var player_reference : CharacterBody2D
@export var despawn_distance : float = 1000
@export var crit_color : Color = Color(1, 0.15, 0.15)
@export var elite_health_multiplier : float = 10.0
@export var xp_gem_tiers : Array[Pickups] = []
@export var xp_tier_strengths : Array[float] = [1.75, 3.0]
var damage_popup_node = preload( "res://scenes/DamagePopup/damage.tscn")
var speed : float = 60
var damage : float
var knockback : Vector2
var separation : float
var hit_cooldown : float = 0.0
var dying : bool = false
var movement : Node
var heal_drop_chance : float
var xp_tier : int = 0
var immune_left : float = 0.0


var health : float:
	set(value):
		health = value
		if health <= 0 and not dying:
			die()

var elite : bool = false:
	set(value):
		elite = value
		if value:
			%Sprite.material = load("res://scenes/Enemy/elite_enemy_material.tres")
			scale = Vector2(1.5,1.5)
			health *= elite_health_multiplier

var type : Enemy:
	set(value):
		type = value
		%Sprite.sprite_frames = value.sprite_frames
		%Sprite.self_modulate = value.tint
		%Sprite.scale = Vector2.ONE * 2.0 * value.size
		%Body.shape.radius = value.collision_radius
		damage = value.damage
		health = value.health
		speed = value.speed
		heal_drop_chance = value.heal_drop_chance
		if value.airborne:
			collision_mask = 0
			z_index = 1


func _ready() -> void:
	movement = (type.movement if type.movement else CHASE).instantiate()
	add_child(movement)
	for ability_scene in type.abilities:
		var ability = ability_scene.instantiate()
		ability.setup(self)
		add_child(ability)
	%AttackSound.stream = type.attack_sound
	%Sprite.play(&"move")


func _physics_process(delta):
	check_separation(delta)
	hit_cooldown -= delta
	update_immunity(delta)
	knockback_update(delta)
	face(velocity)

func check_separation(_delta):
	separation = (player_reference.position - position).length()

	if separation < player_reference.nearest_enemy_distance:
		player_reference.nearest_enemy = self
		player_reference.nearest_enemy_distance = separation

	if separation >= despawn_distance and not elite and not type.boss:
		queue_free()

func knockback_update(delta):
	velocity = movement.steer(self, delta)
	knockback = knockback.move_toward(Vector2.ZERO, 1)
	velocity += knockback
	var collision = move_and_collide(velocity * delta)
	if collision:
		react_to(collision)


func react_to(collision: KinematicCollision2D) -> void:
	var other := collision.get_collider()
	if other.is_in_group("Enemy"):
		other.knockback = (other.global_position - global_position).normalized() * 50
	else:
		move_and_collide(collision.get_remainder().slide(collision.get_normal()))


func face(motion: Vector2) -> void:
	var heading := motion.x if absf(motion.x) > 1.0 else player_reference.global_position.x - global_position.x
	%Sprite.flip_h = (heading > 0.0) if type.faces_left else (heading < 0.0)


func apply_strength(strength : float) -> void:
	health *= strength
	damage *= strength
	xp_tier = 0
	for threshold in xp_tier_strengths:
		if strength >= threshold:
			xp_tier += 1


func make_immune(seconds : float) -> void:
	immune_left = seconds
	%Sprite.modulate.a = 0.5


func update_immunity(delta : float) -> void:
	if immune_left <= 0.0:
		return
	immune_left -= delta
	if immune_left <= 0.0:
		%Sprite.modulate.a = 1.0


func play_cast() -> void:
	%AttackSound.play()
	play_animation(&"cast" if %Sprite.sprite_frames.has_animation(&"cast") else &"attack")


func play_animation(animation : StringName) -> void:
	if %Sprite.sprite_frames.has_animation(animation):
		%Sprite.play(animation)


func try_hit() -> float:
	if hit_cooldown > 0.0 or dying:
		return 0.0
	hit_cooldown = type.attack_interval
	play_attack()
	return damage


func play_attack() -> void:
	%AttackSound.play()
	if %Sprite.sprite_frames.has_animation(&"attack"):
		%Sprite.play(&"attack")


func _on_sprite_animation_finished() -> void:
	if %Sprite.animation in [&"attack", &"cast"]:
		%Sprite.play(&"move")


func die() -> void:
	dying = true
	died.emit()
	get_tree().call_group(&"kill_counter", &"count_kill")
	drop_pickup()
	spawn_death_fx()
	explode()
	split()
	queue_free()


func explode() -> void:
	if type.death_explosion_damage <= 0.0:
		return
	var blast = EXPLOSION.instantiate()
	blast.position = position
	blast.damage = type.death_explosion_damage
	blast.scale = Vector2.ONE * type.death_explosion_radius / 32.0
	get_tree().current_scene.add_child.call_deferred(blast)


func split() -> void:
	if type.splits_into == null:
		return
	var scene: PackedScene = load(ENEMY_SCENE_PATH)
	for index in type.split_count:
		var piece = scene.instantiate()
		piece.type = type.splits_into
		piece.player_reference = player_reference
		piece.position = position + Vector2.RIGHT.rotated(TAU * index / type.split_count) * type.collision_radius
		piece.make_immune(0.4)
		get_tree().current_scene.add_child.call_deferred(piece)


func spawn_death_fx() -> void:
	var fx = DEATH_FX.instantiate()
	fx.sound = type.death_sound
	fx.position = position
	fx.scale = Vector2.ONE * maxf(1.0, type.size)
	get_tree().current_scene.add_child.call_deferred(fx)


func pickup_type() -> Pickups:
	if elite:
		return ELITE_DROP
	return type.drop if type.drop else xp_gem_tiers[mini(xp_tier, xp_gem_tiers.size() - 1)]


func drop_pickup():
	spawn_pickup(pickup_type())
	if randf() < heal_drop_chance:
		spawn_pickup(HEAL_DROP, Vector2(16, 0))


func spawn_pickup(pickup_resource : Pickups, offset := Vector2.ZERO):
	var pickup = PICKUP_SCENE.instantiate()
	pickup.type = pickup_resource
	pickup.player_reference = player_reference
	pickup.position = position + offset
	# deferred: enemies die inside body_entered, posting an Area2D to the tree
	# mid-flush is refused by the physics server
	get_tree().current_scene.add_child.call_deferred(pickup)


func damage_popup(amount, crit := false):
	var popup = damage_popup_node.instantiate()
	popup.text = str(roundi(amount))
	if crit:
		popup.add_theme_color_override("font_color", crit_color)
	popup.position = position + Vector2(-50,-25)
	get_tree().current_scene.add_child(popup)
	# animation + queue_free live in damage.gd, on the popup itself


func take_damage(amount, crit := false):
	if immune_left > 0.0:
		return
	var tween = get_tree().create_tween()
	tween.tween_property(%Sprite, "modulate", Color(3, 0.25, 0.25), 0.2)
	tween.chain().tween_property(%Sprite, "modulate", Color(1, 1, 1), 0.2)
	tween.bind_node(self)

	damage_popup(amount, crit)
	get_tree().call_group(&"hit_sounds", &"play_hit")
	ParticleFX.emit_at(self, &"spark", position)
	if crit:
		ParticleFX.emit_at(self, &"blood", position)
	health -= amount
