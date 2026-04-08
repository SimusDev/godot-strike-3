extends Control

func _ready() -> void:
	draw.connect(_on_visibility_changed.bind(true))
	hidden.connect(_on_visibility_changed.bind(false))
	_on_visibility_changed(is_visible_in_tree())

func _on_visibility_changed(value: bool) -> void:
	if value:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
