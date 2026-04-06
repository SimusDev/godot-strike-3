extends Control
class_name PlayerUI

static var instance: PlayerUI

func _enter_tree() -> void:
	instance = self
