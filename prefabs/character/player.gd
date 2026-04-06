extends CharacterBody3D
class_name Player

static var _local: Player

static func get_local() -> Player:
	if is_instance_valid(_local):
		return _local
	return null

func is_local() -> bool:
	return self == get_local()

func _ready() -> void:
	if SimusNet.is_network_authority(self):
		_local = self
	
	
