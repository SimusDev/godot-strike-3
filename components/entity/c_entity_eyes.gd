extends Node
class_name C_EntityEyes

@export var _entity: Node3D
@export var _camera: Node3D

func _ready() -> void:
	SD_ECS.append_to(_entity, self)

func get_entity() -> Node3D:
	return _entity

func get_camera() -> Node3D:
	return _camera
