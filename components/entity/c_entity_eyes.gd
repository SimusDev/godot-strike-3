extends Node
class_name C_EntityEyes

@export var _entity: Node3D
@export var _camera: Node3D

@export var default_camera_fov: float = 75

func _ready() -> void:
	SD_ECS.append_to(_entity, self)

func get_entity() -> Node3D:
	return _entity

func get_camera() -> Node3D:
	return _camera

func reset_camera_fov() -> C_EntityEyes:
	set_camera_fov(default_camera_fov)
	return self

func set_camera_fov(value: float) -> C_EntityEyes:
	if _camera is Camera3D:
		_camera.fov = value
	
	for camera: Camera3D in SD_ECS.find_children_by_class(_camera, "Camera3D"):
		camera.fov = value
	
	return self
