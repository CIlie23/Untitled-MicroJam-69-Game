extends Resource
class_name Item

@export var title: String
@export var texture: Texture2D
@export_multiline var description: String
@export var max_level: int = 10


func card_text(_level: int) -> String:
	return description
