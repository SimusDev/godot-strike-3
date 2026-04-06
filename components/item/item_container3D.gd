extends Node3D
class_name C_ItemContainer3D

@export_group("Optional")
@export var player: Player

func _ready() -> void:
	
	var enable_input: bool = false
	if player:
		enable_input = player.is_local()
	
	set_process_input(enable_input)
