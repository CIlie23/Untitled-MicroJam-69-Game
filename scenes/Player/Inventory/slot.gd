extends PanelContainer
@onready var texture_rect: TextureRect = $TextureRect
@onready var coldown: Timer = $Coldown

# $paths, not the @onready vars: world.tscn assigns weapon while the scene is
# still instantiating, before _ready fills the @onready vars in.
@export var weapon : Weapon:
	set(value):
		weapon = value
		$TextureRect.texture = value.texture
		$Coldown.wait_time = value.cooldown


func _on_coldown_timeout() -> void:
	# owner is the world root, not the player; the player is the shooter.
	var player = get_tree().get_first_node_in_group("Player")
	if weapon and player:
		coldown.wait_time = weapon.cooldown
		weapon.activate(player, _aim(player), get_tree())


# In control the mouse picks the target; possessed, the other soul aims itself.
# Returns a world position, which weapons accept in place of a node.
func _aim(player):
	if player.possessed:
		return player.nearest_enemy
	return player.get_global_mouse_position()
