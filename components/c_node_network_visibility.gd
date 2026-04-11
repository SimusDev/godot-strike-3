@tool
class_name C_NodeNetworkVisibility extends Node

enum Mode {
	NOT_AUTHORITY,
	AUTHORITY,
	ALWAYS,
}

@export var mode:Mode = Mode.NOT_AUTHORITY :
	set(val):
		mode = val
		
		_update()

@export_group("Custom")
@export var _custom_target:Node :
	set(val):
		if _custom_target:
			_custom_target.show()
		
		_custom_target = val
		_update()

var _target:Node

func get_target() -> Node:
	if _custom_target:
		return _custom_target
	
	return _target

func _ready() -> void:
	_update()
	_auto_bind_target()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PARENTED:
		_auto_bind_target()

func _auto_bind_target() -> void:
	_target = get_parent()

func _update():
	if Engine.is_editor_hint():
		return
	
	var target = get_target()
	
	if not target:
		return
	
	if mode == Mode.ALWAYS:
		target.visible = true
	elif mode == Mode.AUTHORITY:
		target.visible = is_multiplayer_authority()
	elif mode == Mode.NOT_AUTHORITY:
		target.visible = !is_multiplayer_authority()
