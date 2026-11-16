extends Resource
class_name Pickups

@export var title : String
@export var icon : Texture2D
@export_multiline var description: String
@export var shine_scale: float = 0.6
@export var icon_scale: float = 2.0
@export var pickup_sound: AudioStream

var player_reference : CharacterBody2D

func activate():
	player_reference.play_pickup_sound(pickup_sound)
