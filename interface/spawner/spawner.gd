extends Control

@export var _container: Control
@export var _item_scene: PackedScene

func _ready() -> void:
	for resource in s_GameObjects.get_loaded_resources():
		if resource is R_WorldObject:
			_add_object(resource)

func _add_object(object: R_WorldObject) -> void:
	var ui: Control = _item_scene.instantiate()
	ui.object = object
	_container.add_child(ui)
