extends CharacterBody2D

signal possession_changed(possessed: bool)
signal health_changed(health: float, max_health: float)
signal hurt
signal leveled_up
signal xp_stolen(amount: float)


const SPEED = 220.0
@export var base_max_health: float = 100.0
var max_health: float = 100.0
@export var heal_per_level: float = 5.0
@export var invincible: bool = false
@export var base_magnet_radius: float = 114.5
@export var invulnerability_time: float = 0.4
@export var unpossess_heal_min: int = 5
@export var unpossess_heal_max: int = 15
@export var dust_step: float = 20.0
@export var feet_offset: Vector2 = Vector2(0, 28)

# enemies re-assert themselves every physics tick; weapons read nearest_enemy
var nearest_enemy : Node2D
var nearest_enemy_distance : float = INF

var level : int = 1:
	set(value):
		level = value
		leveled_up.emit()
		_update_hud()
		heal_on_level_up()
		%PickCard.show_options()


var dead : bool = false
# the other soul is driving: no input, but weapons keep firing on their own
var possessed : bool = false:
	set(value):
		if value == possessed:
			return
		possessed = value
		possession_changed.emit(value)
		if possessed:
			health_before_possession = health
			health = max_health
		else:
			health = minf(health_before_possession + randi_range(unpossess_heal_min, unpossess_heal_max), max_health)
var health_before_possession : float
var distance_walked : float = 0.0
var invulnerable_left : float = 0.0
var stolen_xp : float = 0.0
var controls_locked : bool = false


var health : float = 100.0 :
	set(value):
		health = maxf(value, 1.0) if invincible else value
		health_changed.emit(health, max_health)
		if health <= 0 and not dead:
			die()

var XP : int = 0:
	set(value):
		XP = value
		_update_hud()
var total_XP : int = 0
# gems the body picked up this run, whoever was driving
var souls : int = 0


func _ready() -> void:
	_update_hud()
	health_changed.emit(health, max_health)


# +5 per level, never capped; 10, 15, 20, 25 ...
func _xp_needed() -> int:
	return 10 + (level - 1) * 5


func _update_hud() -> void:
	%XP.max_value = _xp_needed()
	%XP.value = XP
	%Level.text = "LVL %d" % level


func _physics_process(delta):
# enemies added to the world after the player, so this reset lands before they compare
	nearest_enemy_distance = INF
	if controls_locked:
		velocity = Vector2.ZERO
		%Sprite.show_motion(velocity)
		return
	if possessed:
		velocity = %SoulBrain.steer(self, living_nearest_enemy()) * current_speed()
		move_and_slide()
		if get_slide_collision_count() > 0:
			%SoulBrain.bump()
		%Sprite.show_motion(velocity)
		leave_dust(velocity.length() * delta)
		return
# setup direction of movement
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
# stop diagonal movement by listening for input then setting axis to zero
	if Input.is_action_pressed("move_right") || Input.is_action_pressed("move_left"):
		direction.y = 0
	elif Input.is_action_pressed("move_up") || Input.is_action_pressed("move_down"):
		direction.x = 0
	else:
		direction = Vector2.ZERO
	
#normalize the directional movement
	direction = direction.normalized()
# setup the actual movement
	velocity = direction * current_speed()
	move_and_slide()
	%Sprite.show_motion(velocity)
	leave_dust(velocity.length() * delta)

func leave_dust(step: float) -> void:
	distance_walked += step
	if distance_walked >= dust_step:
		distance_walked -= dust_step
		ParticleFX.emit_at(self, &"dust", global_position + feet_offset)


func living_nearest_enemy() -> Node2D:
	return nearest_enemy if is_instance_valid(nearest_enemy) else null


func heal_on_level_up() -> void:
	if not possessed:
		health = minf(health + heal_per_level, max_health)


func current_speed() -> float:
	return SPEED * %Stats.multiplier(PassiveItem.Stat.MOVE_SPEED)


func play_pickup_sound(sound: AudioStream) -> void:
	if sound == null:
		return
	if %PickupSound.stream != sound:
		%PickupSound.stream = sound
	%PickupSound.play()


func offer_upgrade() -> void:
	%PickCard.show_options()


func heal(amount: float) -> void:
	health = minf(health + amount, max_health)


func take_damage(amount):
	if amount <= 0 or invulnerable_left > 0.0:
		return
	invulnerable_left = invulnerability_time
	health -= amount
	hurt.emit()


# the real loss: failed the typing attempt, or the soul built a full-bar lead
func die() -> void:
	if dead:
		return
	dead = true
	possessed = false
	health = 0
	%TypingChallenge.stop() # silent: the caller is not listening any more
	%DeathScreen.show_death()

func _on_area_2d_body_entered(body: Node2D) -> void:
	take_damage(body.try_hit())


func _on_contact_damage_timeout() -> void:
	for body in %SelfDamage.get_overlapping_bodies():
		take_damage(body.try_hit())


func _on_timer_timeout() -> void:
	pass # Replace with function body.

func check_XP():
	# while, not if: one big gain can clear several levels
	while XP >= _xp_needed():
		XP -= _xp_needed()
		level += 1


func gain_XP(amount):
	souls += 1
	%Souls.text = str(souls)
	# shared body: kills feed both souls, the player keeps the larger share.
	# Possessed, the soul farms alone and the player stops levelling.
	if possessed:
		stolen_xp += amount
		xp_stolen.emit(amount)
		return
	var gained := roundi(amount * %Stats.multiplier(PassiveItem.Stat.XP_GAIN))
	XP += gained
	total_XP += gained
	%VersusBar.player_earned(amount, _xp_needed())
	check_XP()


func _on_magnet_area_entered(area: Area2D) -> void:
	if area.has_method("follow"):
		area.follow(self)


func _process(delta: float) -> void:
	regenerate(delta)
	invulnerable_left -= delta


func regenerate(delta: float) -> void:
	var regen: float = %Stats.bonus(PassiveItem.Stat.HP_REGEN)
	if regen > 0.0 and not dead and health < max_health:
		health = minf(health + regen * delta, max_health)


func _on_stats_changed() -> void:
	%MagnetShape.shape.radius = base_magnet_radius * %Stats.multiplier(PassiveItem.Stat.PICKUP_RANGE)
	var new_max: float = base_max_health * %Stats.multiplier(PassiveItem.Stat.MAX_HEALTH)
	var gained: float = new_max - max_health
	max_health = new_max
	health += gained
