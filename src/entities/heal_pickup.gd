extends Pickups
class_name HealPickup

@export var heal : float = 20.0

func activate():
	super.activate()
	player_reference.heal(heal)
