extends Pickups
class_name CardPickup

func activate():
	super.activate()
	player_reference.offer_upgrade()
