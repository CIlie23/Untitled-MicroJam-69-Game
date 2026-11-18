extends Resource
class_name Enemy

@export var title : String
@export var sprite_frames : SpriteFrames
@export var faces_left : bool = false
@export var tint : Color = Color.WHITE
@export var size : float = 1.0
@export var collision_radius : float = 14.0

@export_group("Stats")
@export var health : float
@export var damage : float
@export var attack_interval : float = 0.5
@export var speed : float = 75.0
@export var airborne : bool = false
@export var boss : bool = false
@export var drop : Pickups
@export_range(0.0, 1.0) var heal_drop_chance : float = 0.02

@export_group("On Death")
@export var death_explosion_damage : float = 0.0
@export var death_explosion_radius : float = 60.0
@export var splits_into : Enemy
@export var split_count : int = 0

@export_group("Spawning")
@export var spawn_weight : float = 1.0
@export var unlock_time : float = 0.0
@export var group_size : Vector2i = Vector2i(1, 1)

@export_group("Behaviour")
@export var movement : PackedScene
@export var abilities : Array[PackedScene] = []

@export_group("Sound")
@export var attack_sound : AudioStream
@export var death_sound : AudioStream
