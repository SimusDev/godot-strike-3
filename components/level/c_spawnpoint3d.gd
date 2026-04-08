extends Node3D
class_name C_SpawnPoint3D

var _level: C_Level3D

func get_level() -> C_Level3D:
	return _level

func _enter_tree() -> void:
	_level = C_Level3D.find_above(self)
	_level._spawnpoints.append(self)

func _exit_tree() -> void:
	if _level:
		_level._spawnpoints.erase(self)
