extends VBoxContainer

var weapon: WeaponNode


func _ready() -> void:
	%Icon.texture = weapon.data.texture


func _process(_delta: float) -> void:
	%Bar.value = charge()


func charge() -> float:
	var timer := weapon.cooldown
	if timer.is_stopped():
		return 1.0
	return 1.0 - timer.time_left / timer.wait_time
