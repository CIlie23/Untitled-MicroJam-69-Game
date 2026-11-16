extends AudioStreamPlayer


func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	if node is BaseButton:
		node.pressed.connect(play.bind(0.0))
