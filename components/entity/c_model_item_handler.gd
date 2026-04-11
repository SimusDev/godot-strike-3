class_name C_ModelItemHandler3D extends Node3D

@export var item_container:C_ItemContainer3D

var _current_item:Node

func _enter_tree() -> void:
	if not item_container:
		return
	
	item_container.object_changed.connect(_on_object_changed)

func _on_object_changed(object:R_WorldObject) -> void:
	if is_instance_valid(_current_item):
		_current_item.queue_free()
	
	if not object:
		return
	
	var viewmodel:R_ViewModel = object.viewmodel
	
	_current_item = viewmodel.instantiate_view()
	
	if _current_item:
		add_child(_current_item)
		
